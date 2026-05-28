import { spawn, spawnSync, type ChildProcess } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { discoverAgents, type AgentConfig, type AgentScope } from "./agents.ts";

type Status = "queued" | "starting" | "running" | "waiting" | "done" | "failed" | "stopped";

type WorktreeSpec = {
	path?: string;
	branch?: string;
	base?: string;
	create?: boolean;
	force?: boolean;
};

type Run = {
	id: string;
	name: string;
	agent?: string;
	task: string;
	cwd: string;
	worktree?: WorktreeSpec & { created?: boolean };
	status: Status;
	startedAt: number;
	endedAt?: number;
	lastEventAt: number;
	lastTool?: string;
	lastText?: string;
	finalOutput?: string;
	error?: string;
	pid?: number;
	proc?: ChildProcess;
	transcript: string[];
};

const runs = new Map<string, Run>();
let currentCtx: any | undefined;
let nextId = 1;
let lastWidgetText: string | undefined;

function shortId(): string {
	return `sa-${Date.now().toString(36)}-${nextId++}`;
}

function elapsed(ms: number): string {
	const s = Math.max(0, Math.floor((Date.now() - ms) / 1000));
	const m = Math.floor(s / 60);
	const r = s % 60;
	return `${m.toString().padStart(2, "0")}:${r.toString().padStart(2, "0")}`;
}

function truncate(s: string, n: number): string {
	const one = s.replace(/\s+/g, " ").trim();
	return one.length <= n ? one : `${one.slice(0, Math.max(0, n - 1))}…`;
}

function statusIcon(status: Status): string {
	return ({ queued: "◌", starting: "…", running: "▶", waiting: "?", done: "✓", failed: "✗", stopped: "■" } as const)[status];
}

function isActiveStatus(status: Status): boolean {
	return ["queued", "starting", "running", "waiting"].includes(status);
}

function renderRunRow(r: Run): string {
	const activity = r.lastTool ? r.lastTool : r.lastText ? truncate(r.lastText, 24) : r.worktree?.path ? path.basename(r.worktree.path) : "";
	return `${statusIcon(r.status)} ${elapsed(r.startedAt)} ${r.name.padEnd(18).slice(0, 18)} ${r.status.padEnd(8)} ${truncate(activity, 34)}`;
}

function renderLines(): string[] {
	const all = Array.from(runs.values()).sort((a, b) => b.startedAt - a.startedAt);
	const activeRuns = all.filter((r) => isActiveStatus(r.status));
	if (activeRuns.length === 0) return [];
	const rows = activeRuns.slice(0, 8).map(renderRunRow);
	return [`Subagents: ${activeRuns.length} active / ${all.length} total  (/subagents for details)`, ...rows];
}

function renderAllLines(): string[] {
	const all = Array.from(runs.values()).sort((a, b) => b.startedAt - a.startedAt);
	if (all.length === 0) return [];
	const active = all.filter((r) => isActiveStatus(r.status)).length;
	const rows = all.slice(0, 20).map(renderRunRow);
	return [`Subagents: ${active} active / ${all.length} total`, ...rows];
}

function findRun(idOrName: string): Run | undefined {
	return runs.get(idOrName) || Array.from(runs.values()).find((r) => r.name === idOrName);
}

function stopRun(run: Run): void {
	run.status = "stopped";
	run.endedAt = run.endedAt || Date.now();
	run.proc?.kill("SIGTERM");
	setTimeout(() => run.proc && !run.proc.killed && run.proc.kill("SIGKILL"), 5000).unref?.();
}

function clearFinishedRuns(): number {
	let removed = 0;
	for (const [id, run] of runs) {
		if (!isActiveStatus(run.status)) {
			runs.delete(id);
			removed++;
		}
	}
	return removed;
}

function clearAllRuns(): number {
	const count = runs.size;
	for (const run of runs.values()) {
		if (isActiveStatus(run.status)) stopRun(run);
	}
	runs.clear();
	return count;
}

function updateWidget(force = false) {
	if (!currentCtx?.hasUI) return;
	const lines = renderLines();
	if (lines.length === 0) {
		// Always send an explicit clear when no subagents are active. The UI may
		// still have a widget from a previous extension instance/reload even when
		// this in-memory cache thinks it is already clear.
		lastWidgetText = undefined;
		currentCtx.ui.setWidget("orchestrator-subagents", undefined, { placement: "belowEditor" });
		return;
	}
	const nextWidgetText = lines.join("\n");
	if (!force && nextWidgetText === lastWidgetText) return;
	lastWidgetText = nextWidgetText;
	currentCtx.ui.setWidget("orchestrator-subagents", lines, { placement: "belowEditor" });
}

function finalAssistantTextFromMessage(message: any): string {
	if (!message || message.role !== "assistant" || !Array.isArray(message.content)) return "";
	const texts = message.content.filter((p: any) => p?.type === "text").map((p: any) => p.text || "");
	return texts.join("\n").trim();
}

function maybeNotifyMain(run: Run) {
	const body = run.status === "waiting"
		? `Subagent ${run.name} needs direction.\n\n${run.finalOutput || run.lastText || ""}`
		: run.status === "done"
			? `Subagent ${run.name} completed.\n\n${run.finalOutput || "(no output)"}`
			: `Subagent ${run.name} ${run.status}.\n\n${run.error || run.finalOutput || ""}`;
	try {
		currentCtx?.ui?.notify?.(`${run.name}: ${run.status}`, run.status === "failed" ? "error" : "info");
	} catch {}
	try {
		// Wake the coordinator agent so it can decide whether to ask the user, respond, merge, or spawn follow-ups.
		(currentCtx ? undefined : null);
		// Use pi-level API via captured global in register function below.
	} catch {}
	return body;
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
	if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}
	const execName = path.basename(process.execPath).toLowerCase();
	const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
	return isGenericRuntime ? { command: "pi", args } : { command: process.execPath, args };
}

async function writeTempPrompt(systemPrompt: string): Promise<{ dir: string; file: string }> {
	const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-orchestrator-"));
	const file = path.join(dir, "system.md");
	await withFileMutationQueue(file, () => fs.promises.writeFile(file, systemPrompt, "utf8"));
	return { dir, file };
}

function runGit(cwd: string, args: string[]): { ok: boolean; stdout: string; stderr: string } {
	const r = spawnSync("git", args, { cwd, encoding: "utf8" });
	return { ok: r.status === 0, stdout: r.stdout || "", stderr: r.stderr || "" };
}

function ensureWorktree(defaultCwd: string, spec: WorktreeSpec | undefined, name: string): { cwd: string; worktree?: Run["worktree"] } {
	if (!spec) return { cwd: defaultCwd };
	const root = runGit(defaultCwd, ["rev-parse", "--show-toplevel"]);
	if (!root.ok) throw new Error(`Not inside a git repository: ${root.stderr}`);
	const repoRoot = root.stdout.trim();
	const branchSafe = (spec.branch || `agent/${name.toLowerCase().replace(/[^a-z0-9._/-]+/g, "-")}-${Date.now().toString(36)}`).replace(/^\/+/, "");
	const wtPath = path.resolve(repoRoot, spec.path || path.join("..", `${path.basename(repoRoot)}-${branchSafe.replace(/[^a-z0-9._-]+/gi, "-")}`));
	if (fs.existsSync(wtPath)) return { cwd: wtPath, worktree: { ...spec, path: wtPath, branch: branchSafe, created: false } };
	if (spec.create === false) throw new Error(`Worktree path does not exist: ${wtPath}`);
	const args = ["worktree", "add"];
	if (spec.force) args.push("--force");
	args.push("-b", branchSafe, wtPath);
	if (spec.base) args.push(spec.base);
	const added = runGit(repoRoot, args);
	if (!added.ok) throw new Error(`git ${args.join(" ")} failed:\n${added.stderr || added.stdout}`);
	return { cwd: wtPath, worktree: { ...spec, path: wtPath, branch: branchSafe, created: true } };
}

function startRun(pi: ExtensionAPI, run: Run, agent: AgentConfig | undefined, model?: string, tools?: string, systemPrompt?: string) {
	void (async () => {
		let tmp: { dir: string; file: string } | undefined;
		try {
			run.status = "starting";
			updateWidget();
			const args = ["--mode", "json", "-p", "--no-session"];
			const chosenModel = model || agent?.model;
			const chosenTools = tools || agent?.tools?.join(",");
			const promptParts = [
				agent?.systemPrompt || "",
				systemPrompt || "",
				"You are an autonomous subagent coordinated by a parent Pi session.",
				"Work only on your assigned task and cwd/worktree. Report concise progress in normal assistant text.",
				"If blocked and you need direction from the parent, end your response with a line starting exactly: NEEDS_INPUT: followed by the question.",
				"When complete, summarize changed files, tests run, and any merge notes.",
			].filter(Boolean).join("\n\n");
			if (chosenModel) args.push("--model", chosenModel);
			if (chosenTools) args.push("--tools", chosenTools);
			if (promptParts.trim()) {
				tmp = await writeTempPrompt(promptParts);
				args.push("--append-system-prompt", tmp.file);
			}
			args.push(`Task for subagent ${run.name} (${run.id}):\n\n${run.task}\n\nWorking directory: ${run.cwd}`);
			const inv = getPiInvocation(args);
			const proc = spawn(inv.command, inv.args, { cwd: run.cwd, stdio: ["ignore", "pipe", "pipe"] });
			run.proc = proc;
			run.pid = proc.pid;
			run.status = "running";
			run.lastEventAt = Date.now();
			updateWidget();
			let buffer = "";
			proc.stdout?.on("data", (chunk) => {
				buffer += chunk.toString();
				const lines = buffer.split("\n");
				buffer = lines.pop() || "";
				for (const line of lines) processJsonLine(run, line);
			});
			proc.stderr?.on("data", (chunk) => {
				const s = chunk.toString();
				run.error = truncate((run.error ? `${run.error}\n` : "") + s, 2000);
			});
			proc.on("close", (code) => {
				if (buffer.trim()) processJsonLine(run, buffer);
				run.endedAt = Date.now();
				if (run.status !== "stopped") {
					if (code === 0) {
						run.status = /(^|\n)NEEDS_INPUT:/m.test(run.finalOutput || "") ? "waiting" : "done";
					} else {
						run.status = "failed";
						run.error = run.error || `Subagent exited with code ${code}`;
					}
				}
				updateWidget();
				const body = maybeNotifyMain(run);
				pi.sendMessage({ customType: "orchestrator", content: body, display: true, details: publicRun(run) }, { triggerTurn: true, deliverAs: "followUp" });
				if (tmp) cleanupTmp(tmp);
			});
			proc.on("error", (err) => {
				run.status = "failed";
				run.error = err.message;
				run.endedAt = Date.now();
				updateWidget();
				pi.sendMessage({ customType: "orchestrator", content: maybeNotifyMain(run), display: true, details: publicRun(run) }, { triggerTurn: true, deliverAs: "followUp" });
				if (tmp) cleanupTmp(tmp);
			});
		} catch (err: any) {
			run.status = "failed";
			run.error = err?.message || String(err);
			run.endedAt = Date.now();
			updateWidget();
			pi.sendMessage({ customType: "orchestrator", content: maybeNotifyMain(run), display: true, details: publicRun(run) }, { triggerTurn: true, deliverAs: "followUp" });
			if (tmp) cleanupTmp(tmp);
		}
	})();
}

function processJsonLine(run: Run, line: string) {
	if (!line.trim()) return;
	let event: any;
	try { event = JSON.parse(line); } catch { return; }
	run.lastEventAt = Date.now();
	if (event.type === "tool_execution_start") run.lastTool = event.toolName;
	if (event.type === "tool_execution_end") run.lastTool = undefined;
	if (event.type === "message_end") {
		const text = finalAssistantTextFromMessage(event.message);
		if (text) {
			run.lastText = text;
			run.finalOutput = text;
			run.transcript.push(text);
			if (run.transcript.length > 20) run.transcript.shift();
		}
	}
	updateWidget();
}

function cleanupTmp(tmp: { dir: string; file: string }) {
	try { fs.unlinkSync(tmp.file); } catch {}
	try { fs.rmdirSync(tmp.dir); } catch {}
}

function publicRun(r: Run) {
	return {
		id: r.id, name: r.name, agent: r.agent, task: r.task, cwd: r.cwd, worktree: r.worktree,
		status: r.status, startedAt: r.startedAt, endedAt: r.endedAt, lastTool: r.lastTool,
		lastText: r.lastText, finalOutput: r.finalOutput, error: r.error, pid: r.pid,
	};
}

const WorktreeSchema = Type.Object({
	path: Type.Optional(Type.String({ description: "Worktree path. Defaults to ../<repo>-<branch>." })),
	branch: Type.Optional(Type.String({ description: "Branch name to create/use. Defaults to agent/<name>-<timestamp>." })),
	base: Type.Optional(Type.String({ description: "Base ref for new worktree branch." })),
	create: Type.Optional(Type.Boolean({ description: "Create missing worktree. Default true." })),
	force: Type.Optional(Type.Boolean({ description: "Pass --force to git worktree add." })),
});

export default function orchestrator(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		currentCtx = ctx;
		updateWidget(true);
	});
	pi.on("session_shutdown", () => {
		try { currentCtx?.ui?.setWidget?.("orchestrator-subagents", undefined, { placement: "belowEditor" }); } catch {}
		lastWidgetText = undefined;
		currentCtx = undefined;
	});

	pi.registerTool({
		name: "subagent_spawn",
		label: "Spawn subagent",
		description: "Start an async Pi subagent coordinated by the main session. Supports optional git worktree creation.",
		parameters: Type.Object({
			name: Type.String({ description: "Short display name for the subagent." }),
			task: Type.String({ description: "Full task prompt. Include all context the isolated child needs." }),
			agent: Type.Optional(Type.String({ description: "Agent definition name from ~/.pi/agent/agents or .pi/agents." })),
			agentScope: Type.Optional(Type.Union([Type.Literal("user"), Type.Literal("project"), Type.Literal("both")], { default: "user" })),
			cwd: Type.Optional(Type.String({ description: "Working directory. Ignored if worktree is provided." })),
			worktree: Type.Optional(WorktreeSchema),
			model: Type.Optional(Type.String({ description: "Model override." })),
			tools: Type.Optional(Type.String({ description: "Comma-separated Pi tools override." })),
			systemPrompt: Type.Optional(Type.String({ description: "Additional child system prompt." })),
		}),
		async execute(_id, params, _signal, _onUpdate, ctx) {
			const scope: AgentScope = params.agentScope ?? "user";
			const agents = discoverAgents(ctx.cwd, scope).agents;
			const agent = params.agent ? agents.find((a) => a.name === params.agent) : undefined;
			if (params.agent && !agent) {
				return { content: [{ type: "text", text: `Unknown agent ${params.agent}. Available: ${agents.map((a) => a.name).join(", ") || "none"}` }], isError: true };
			}
			const wt = ensureWorktree(ctx.cwd, params.worktree, params.name);
			const cwd = params.worktree ? wt.cwd : path.resolve(ctx.cwd, params.cwd || ".");
			const run: Run = { id: shortId(), name: params.name, agent: params.agent, task: params.task, cwd, worktree: wt.worktree, status: "queued", startedAt: Date.now(), lastEventAt: Date.now(), transcript: [] };
			runs.set(run.id, run);
			updateWidget();
			startRun(pi, run, agent, params.model, params.tools, params.systemPrompt);
			return { content: [{ type: "text", text: `Started subagent ${run.name} (${run.id}) in ${cwd}${run.worktree ? ` on branch ${run.worktree.branch}` : ""}. Watch the status widget or run /subagents.` }], details: publicRun(run) };
		},
	});

	pi.registerTool({
		name: "subagents_list",
		label: "List subagents",
		description: "List async orchestrator subagents and their current status.",
		parameters: Type.Object({}),
		async execute() {
			const data = Array.from(runs.values()).map(publicRun);
			return { content: [{ type: "text", text: data.length ? JSON.stringify(data, null, 2) : "No subagents." }], details: data };
		},
	});

	pi.registerTool({
		name: "subagent_continue",
		label: "Continue subagent",
		description: "Continue a waiting/completed subagent by starting a follow-up run in the same cwd/worktree with prior output and guidance.",
		parameters: Type.Object({
			idOrName: Type.String(),
			message: Type.String({ description: "Guidance or follow-up task from the coordinator/user." }),
			name: Type.Optional(Type.String({ description: "Optional display name for the follow-up run." })),
		}),
		async execute(_id, params, _signal, _onUpdate, ctx) {
			const previous = runs.get(params.idOrName) || Array.from(runs.values()).find((r) => r.name === params.idOrName);
			if (!previous) return { content: [{ type: "text", text: `No subagent found: ${params.idOrName}` }], isError: true };
			const scope: AgentScope = "both";
			const agents = discoverAgents(ctx.cwd, scope).agents;
			const agent = previous.agent ? agents.find((a) => a.name === previous.agent) : undefined;
			const task = [
				`Continue prior subagent ${previous.name} (${previous.id}).`,
				`Original task:\n${previous.task}`,
				previous.finalOutput ? `Prior output:\n${previous.finalOutput}` : undefined,
				`Coordinator guidance:\n${params.message}`,
			].filter(Boolean).join("\n\n---\n\n");
			const run: Run = { id: shortId(), name: params.name || `${previous.name} follow-up`, agent: previous.agent, task, cwd: previous.cwd, worktree: previous.worktree, status: "queued", startedAt: Date.now(), lastEventAt: Date.now(), transcript: [] };
			runs.set(run.id, run);
			updateWidget();
			startRun(pi, run, agent, undefined, undefined, undefined);
			return { content: [{ type: "text", text: `Started follow-up ${run.name} (${run.id}) in ${run.cwd}.` }], details: publicRun(run) };
		},
	});

	pi.registerTool({
		name: "subagent_stop",
		label: "Stop subagent",
		description: "Stop a running subagent process by id or exact name.",
		parameters: Type.Object({ idOrName: Type.String() }),
		async execute(_id, params) {
			const run = findRun(params.idOrName);
			if (!run) return { content: [{ type: "text", text: `No subagent found: ${params.idOrName}` }], isError: true };
			stopRun(run);
			updateWidget();
			return { content: [{ type: "text", text: `Stopped ${run.name} (${run.id}).` }], details: publicRun(run) };
		},
	});

	pi.registerCommand("subagents", {
		description: "Show async subagent status, including completed runs",
		handler: async (_args, ctx) => {
			currentCtx = ctx;
			const lines = renderAllLines();
			ctx.ui.notify(lines.length ? lines.join("\n") : "No subagents", "info");
			updateWidget();
		},
	});

	pi.registerCommand("subagent-stop", {
		description: "Stop a running subagent by id or exact name",
		handler: async (args, ctx) => {
			currentCtx = ctx;
			const idOrName = args.trim();
			if (!idOrName) {
				ctx.ui.notify("Usage: /subagent-stop <id-or-exact-name>", "error");
				return;
			}
			const run = findRun(idOrName);
			if (!run) {
				ctx.ui.notify(`No subagent found: ${idOrName}`, "error");
				return;
			}
			stopRun(run);
			ctx.ui.notify(`Stopped ${run.name} (${run.id}).`, "info");
			updateWidget();
		},
	});

	pi.registerCommand("subagents-clear", {
		description: "Close all subagents and clear /subagents history",
		handler: async (_args, ctx) => {
			currentCtx = ctx;
			const removed = clearAllRuns();
			ctx.ui.notify(`Cleared ${removed} subagent${removed === 1 ? "" : "s"}.`, "info");
			updateWidget(true);
		},
	});
}
