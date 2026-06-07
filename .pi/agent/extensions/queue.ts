import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { complete, type Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext, ReplacedSessionContext, SessionEntry } from "@earendil-works/pi-coding-agent";

const QUEUE_VERSION = 1;
const LONG_TITLE_THRESHOLD = 120;

type QueueStatus = "pending" | "running" | "done" | "cancelled";

type QueueItem = {
	id: string;
	title: string;
	prompt: string;
	sourceSessionFile?: string;
	sourceSessionId?: string;
	sourceEntryId?: string;
	forkSessionFile?: string;
	forkSessionId?: string;
	summary?: string;
	status: QueueStatus;
	createdAt: string;
	updatedAt: string;
};

type QueueFile = {
	version: number;
	items: QueueItem[];
};

type AnyCommandContext = ExtensionCommandContext | ReplacedSessionContext;

type SessionConversation = {
	sessionFile: string;
	messages: Array<{ role: string; text: string }>;
};

function queuePath(cwd: string): string {
	return join(cwd, ".pi", "queue.json");
}

async function loadQueue(cwd: string): Promise<QueueFile> {
	try {
		const parsed = JSON.parse(await readFile(queuePath(cwd), "utf8")) as QueueFile;
		return { version: parsed.version ?? QUEUE_VERSION, items: Array.isArray(parsed.items) ? parsed.items : [] };
	} catch (err: any) {
		if (err?.code === "ENOENT") return { version: QUEUE_VERSION, items: [] };
		throw err;
	}
}

async function saveQueue(cwd: string, queue: QueueFile): Promise<void> {
	const file = queuePath(cwd);
	await mkdir(dirname(file), { recursive: true });
	await writeFile(file, `${JSON.stringify({ version: QUEUE_VERSION, items: queue.items }, null, 2)}\n`, "utf8");
}

function nowIso(): string {
	return new Date().toISOString();
}

function makeId(): string {
	return `q_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}

function shorten(text: string, max = 90): string {
	const compact = text.replace(/\s+/g, " ").trim();
	return compact.length <= max ? compact : `${compact.slice(0, max - 1)}…`;
}

function fallbackTitle(text: string): string {
	const first = text
		.split("\n")
		.map((line) => line.trim())
		.find(Boolean);
	return shorten((first || text).replace(/^[-*+•]\s+/, "").replace(/^\d+[.)]\s+/, ""), 80) || "Queued task";
}

async function generateTitle(text: string, ctx: AnyCommandContext): Promise<string> {
	const fallback = fallbackTitle(text);
	if (text.length < LONG_TITLE_THRESHOLD || !ctx.model) return fallback;

	try {
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
		if (!auth.ok || !auth.apiKey) return fallback;

		const message: Message = {
			role: "user",
			content: [{ type: "text", text: `Create a concise task title, max 8 words, no ending punctuation.\n\nTask:\n${text}` }],
			timestamp: Date.now(),
		};
		const response = await complete(
			ctx.model,
			{ systemPrompt: "You create short todo item titles. Return only the title.", messages: [message] },
			{ apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
		);
		const title = response.content
			.filter((c): c is { type: "text"; text: string } => c.type === "text")
			.map((c) => c.text)
			.join(" ")
			.replace(/[\n\r]+/g, " ")
			.replace(/^['"]|['"]$/g, "")
			.trim();
		return title ? shorten(title, 80) : fallback;
	} catch {
		return fallback;
	}
}

function currentAnchor(ctx: AnyCommandContext) {
	return {
		sourceSessionFile: ctx.sessionManager.getSessionFile(),
		sourceSessionId: ctx.sessionManager.getSessionId(),
		sourceEntryId: ctx.sessionManager.getLeafId() ?? undefined,
	};
}

async function addItem(ctx: AnyCommandContext, prompt: string, title?: string): Promise<QueueItem> {
	const queue = await loadQueue(ctx.cwd);
	const timestamp = nowIso();
	const item: QueueItem = {
		id: makeId(),
		title: title?.trim() || (await generateTitle(prompt, ctx)),
		prompt: prompt.trim(),
		...currentAnchor(ctx),
		status: "pending",
		createdAt: timestamp,
		updatedAt: timestamp,
	};
	queue.items.push(item);
	await saveQueue(ctx.cwd, queue);
	return item;
}

function messageText(message: any): string {
	if (typeof message.content === "string") return message.content;
	if (Array.isArray(message.content)) {
		return message.content
			.filter((c: any) => c.type === "text")
			.map((c: any) => c.text)
			.join("\n")
			.trim();
	}
	if (typeof message.summary === "string") return message.summary;
	if (typeof message.command === "string") return `$ ${message.command}\n${message.output || ""}`.trim();
	return "";
}

function assistantTextFromEntry(entry: SessionEntry): string | undefined {
	if (entry.type !== "message" || entry.message.role !== "assistant") return undefined;
	return messageText(entry.message).trim();
}

function getLastAssistantText(ctx: AnyCommandContext): string | undefined {
	const branch = ctx.sessionManager.getBranch();
	for (let i = branch.length - 1; i >= 0; i--) {
		const text = assistantTextFromEntry(branch[i]);
		if (text) return text;
	}
	return undefined;
}

function extractJsonArray(text: string): unknown {
	const trimmed = text.trim().replace(/^```(?:json)?\s*/i, "").replace(/```$/i, "").trim();
	try {
		return JSON.parse(trimmed);
	} catch {
		const start = trimmed.indexOf("[");
		const end = trimmed.lastIndexOf("]");
		if (start >= 0 && end > start) return JSON.parse(trimmed.slice(start, end + 1));
		throw new Error("No JSON array found");
	}
}

async function generateSplitItems(text: string, ctx: AnyCommandContext): Promise<string[]> {
	if (!ctx.model) throw new Error("No model selected");
	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
	if (!auth.ok || !auth.apiKey) throw new Error("No API key available for selected model");

	const message: Message = {
		role: "user",
		content: [{
			type: "text",
			text: `Split this into the fewest larger independent queue items. Prefer core actionable findings/tasks over metadata bullets; include secondary findings only if actionable. Return only a JSON array of strings, each string containing the full task context.\n\n${text}`,
		}],
		timestamp: Date.now(),
	};
	const response = await complete(
		ctx.model,
		{ systemPrompt: "You split text into coarse actionable queue items. Output only valid JSON.", messages: [message] },
		{ apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
	);
	const raw = response.content
		.filter((c): c is { type: "text"; text: string } => c.type === "text")
		.map((c) => c.text)
		.join("\n");
	const parsed = extractJsonArray(raw);
	if (!Array.isArray(parsed)) throw new Error("Split response was not a JSON array");
	return parsed
		.map((item) => {
			if (typeof item === "string") return item.trim();
			if (item && typeof item === "object") {
				const value = (item as any).prompt ?? (item as any).task ?? (item as any).text;
				return typeof value === "string" ? value.trim() : "";
			}
			return "";
		})
		.filter((item) => item.length > 0);
}

function formatItem(item: QueueItem): string {
	const icon = item.status === "done" ? "✓" : item.status === "running" ? "▶" : item.status === "cancelled" ? "✕" : "○";
	return `${icon} ${item.title}  [${item.id}]`;
}

function itemFromChoice(choice: string | undefined, items: QueueItem[]): QueueItem | undefined {
	if (!choice) return undefined;
	const match = choice.match(/\[(q_[^\]]+)\]$/);
	return match ? items.find((item) => item.id === match[1]) : undefined;
}

async function updateItem(cwd: string, id: string, patch: Partial<QueueItem>): Promise<void> {
	const queue = await loadQueue(cwd);
	const idx = queue.items.findIndex((item) => item.id === id);
	if (idx < 0) return;
	queue.items[idx] = { ...queue.items[idx], ...patch, updatedAt: nowIso() };
	await saveQueue(cwd, queue);
}

async function deleteItem(cwd: string, id: string): Promise<void> {
	const queue = await loadQueue(cwd);
	queue.items = queue.items.filter((item) => item.id !== id);
	await saveQueue(cwd, queue);
}

async function pruneDoneItems(cwd: string): Promise<number> {
	const queue = await loadQueue(cwd);
	const before = queue.items.length;
	queue.items = queue.items.filter((item) => item.status !== "done");
	await saveQueue(cwd, queue);
	return before - queue.items.length;
}

async function clearQueue(cwd: string): Promise<number> {
	const queue = await loadQueue(cwd);
	const count = queue.items.length;
	queue.items = [];
	await saveQueue(cwd, queue);
	return count;
}

function treeChoices(ctx: AnyCommandContext): string[] {
	return ctx.sessionManager.getEntries().map((entry) => {
		const label = ctx.sessionManager.getLabel(entry.id);
		let text = entry.type;
		if (entry.type === "message") {
			const role = entry.message.role;
			const content = typeof entry.message.content === "string"
				? entry.message.content
				: entry.message.content?.filter((c: any) => c.type === "text").map((c: any) => c.text).join(" ");
			text = `${role}: ${shorten(content || "", 70)}`;
		}
		return `${label ? `${label} ` : ""}${entry.id} — ${text}`;
	});
}

function entryIdFromTreeChoice(choice: string | undefined): string | undefined {
	return choice?.match(/(?:^|\s)([0-9a-f]{8})\s+—/)?.[1];
}

async function readSessionConversation(sessionFile: string): Promise<SessionConversation> {
	const raw = await readFile(sessionFile, "utf8");
	const messages: SessionConversation["messages"] = [];
	for (const line of raw.split("\n")) {
		if (!line.trim()) continue;
		let entry: any;
		try {
			entry = JSON.parse(line);
		} catch {
			continue;
		}
		if (entry.type !== "message" || !entry.message) continue;
		const role = entry.message.role || "message";
		const text = messageText(entry.message);
		if (text) messages.push({ role, text });
	}
	return { sessionFile, messages };
}

function serializeForSummary(conversation: SessionConversation): string {
	const joined = conversation.messages
		.map((m) => `## ${m.role}\n${m.text}`)
		.join("\n\n");
	return joined.length <= 20000 ? joined : `${joined.slice(0, 8000)}\n\n[... middle omitted ...]\n\n${joined.slice(-12000)}`;
}

async function summarizeThread(ctx: AnyCommandContext, item: QueueItem): Promise<string> {
	if (!item.forkSessionFile) return `${item.title}: no fork session recorded.`;
	const conversation = await readSessionConversation(item.forkSessionFile);
	const fallback = `${item.title}: ${shorten(conversation.messages.at(-1)?.text || item.prompt, 220)}`;
	if (!ctx.model) return fallback;

	try {
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
		if (!auth.ok || !auth.apiKey) return fallback;
		const message: Message = {
			role: "user",
			content: [
				{
					type: "text",
					text: `Task title: ${item.title}\nOriginal queued prompt:\n${item.prompt}\n\nThread transcript:\n${serializeForSummary(conversation)}\n\nWrite a very short regrouping summary for this completed thread. Include outcome, key decisions, important files changed/read if known, and any remaining follow-up. Max 5 bullets.`,
				},
			],
			timestamp: Date.now(),
		};
		const response = await complete(
			ctx.model,
			{ systemPrompt: "You summarize completed coding-agent branch threads for regrouping. Be concise and concrete.", messages: [message] },
			{ apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
		);
		const summary = response.content
			.filter((c): c is { type: "text"; text: string } => c.type === "text")
			.map((c) => c.text)
			.join("\n")
			.trim();
		return summary || fallback;
	} catch {
		return fallback;
	}
}

async function nameReplacementSession(ctx: ReplacedSessionContext, title: string) {
	try {
		const sm = ctx.sessionManager as any;
		if (typeof sm.appendSessionInfo === "function") sm.appendSessionInfo(`Queue: ${title}`);
	} catch {
		// Best effort only.
	}
}

async function sendPrompt(ctx: AnyCommandContext | ReplacedSessionContext, prompt: string) {
	if ("sendUserMessage" in ctx) {
		await ctx.sendUserMessage(prompt);
		return;
	}
	const pi = activePi;
	if (!ctx.isIdle()) pi.sendUserMessage(prompt, { deliverAs: "followUp" });
	else pi.sendUserMessage(prompt);
}

let activePi: ExtensionAPI;

async function forkAndRun(ctx: AnyCommandContext, item: QueueItem, entryId: string) {
	if (!entryId) {
		ctx.ui.notify("Queue item has no source entry to fork from", "error");
		return;
	}
	await updateItem(ctx.cwd, item.id, { status: "running" });
	const result = await ctx.fork(entryId, {
		position: "at",
		withSession: async (forkCtx) => {
			await nameReplacementSession(forkCtx, item.title);
			await updateItem(forkCtx.cwd, item.id, {
				forkSessionFile: forkCtx.sessionManager.getSessionFile(),
				forkSessionId: forkCtx.sessionManager.getSessionId(),
			});
			await forkCtx.sendUserMessage(item.prompt);
		},
	});
	if (result.cancelled) await updateItem(ctx.cwd, item.id, { status: "pending" });
}

async function runItem(ctx: AnyCommandContext, item: QueueItem, mode: "saved-fork" | "pick-fork" | "current" | "new") {
	if (mode === "current") {
		await updateItem(ctx.cwd, item.id, {
			status: "running",
			forkSessionFile: ctx.sessionManager.getSessionFile(),
			forkSessionId: ctx.sessionManager.getSessionId(),
		});
		await sendPrompt(ctx, item.prompt);
		return;
	}

	if (mode === "new") {
		await updateItem(ctx.cwd, item.id, { status: "running" });
		const parentSession = ctx.sessionManager.getSessionFile();
		const result = await ctx.newSession({
			parentSession,
			setup: async (sm) => {
				sm.appendSessionInfo(`Queue: ${item.title}`);
			},
			withSession: async (newCtx) => {
				await updateItem(newCtx.cwd, item.id, {
					forkSessionFile: newCtx.sessionManager.getSessionFile(),
					forkSessionId: newCtx.sessionManager.getSessionId(),
				});
				await newCtx.sendUserMessage(item.prompt);
			},
		});
		if (result.cancelled) await updateItem(ctx.cwd, item.id, { status: "pending" });
		return;
	}

	const runInSource = async (sourceCtx: AnyCommandContext) => {
		let entryId = item.sourceEntryId;
		if (mode === "pick-fork") {
			const choice = await sourceCtx.ui.select("Fork from which tree entry?", treeChoices(sourceCtx));
			entryId = entryIdFromTreeChoice(choice);
			if (!entryId) return;
		}
		await forkAndRun(sourceCtx, item, entryId || "");
	};

	const currentSessionFile = ctx.sessionManager.getSessionFile();
	if (item.sourceSessionFile && currentSessionFile && item.sourceSessionFile !== currentSessionFile) {
		const ok = await ctx.ui.confirm("Switch sessions?", `This queue item was created in another session. Switch to its source session before forking?\n\n${item.sourceSessionFile}`);
		if (!ok) return;
		await ctx.switchSession(item.sourceSessionFile, { withSession: runInSource });
		return;
	}

	await runInSource(ctx);
}

async function openQueue(ctx: ExtensionCommandContext) {
	const queue = await loadQueue(ctx.cwd);
	if (queue.items.length === 0) {
		ctx.ui.notify("Queue is empty. Add with /queue <task> or /split.", "info");
		return;
	}

	const sorted = [...queue.items].sort((a, b) => a.createdAt.localeCompare(b.createdAt));
	const choice = await ctx.ui.select("Queue", sorted.map(formatItem));
	const item = itemFromChoice(choice, sorted);
	if (!item) return;

	const action = await ctx.ui.select(`Queue: ${item.title}`, [
		"Fork and run from saved point",
		"Fork and run from another tree point",
		"Run in current session",
		"Start new session and run",
		"Edit prompt",
		"Rename",
		"Mark done",
		"Delete",
	]);

	if (action === "Fork and run from saved point") await runItem(ctx, item, "saved-fork");
	else if (action === "Fork and run from another tree point") await runItem(ctx, item, "pick-fork");
	else if (action === "Run in current session") await runItem(ctx, item, "current");
	else if (action === "Start new session and run") await runItem(ctx, item, "new");
	else if (action === "Edit prompt") {
		const edited = await ctx.ui.editor("Edit queue prompt", item.prompt);
		if (edited !== undefined && edited.trim()) await updateItem(ctx.cwd, item.id, { prompt: edited.trim() });
	} else if (action === "Rename") {
		const name = await ctx.ui.input("Rename queue item", item.title);
		if (name?.trim()) await updateItem(ctx.cwd, item.id, { title: name.trim() });
	} else if (action === "Mark done") {
		await updateItem(ctx.cwd, item.id, { status: "done" });
	} else if (action === "Delete") {
		const ok = await ctx.ui.confirm("Delete queue item?", item.title);
		if (ok) await deleteItem(ctx.cwd, item.id);
	}
}

function returnableItems(queue: QueueFile): QueueItem[] {
	return queue.items.filter((item) => item.forkSessionFile && item.sourceSessionFile && item.sourceEntryId && item.status !== "cancelled");
}

async function selectReturnItems(ctx: ExtensionCommandContext, candidates: QueueItem[]): Promise<QueueItem[]> {
	const selected = new Map<string, QueueItem>();
	const currentSession = ctx.sessionManager.getSessionFile();
	const currentItem = candidates.find((item) => item.forkSessionFile === currentSession);
	if (currentItem) selected.set(currentItem.id, currentItem);

	while (true) {
		const options = [
			...(selected.size > 0 ? ["Done selecting"] : []),
			...(candidates.length > 1 ? ["Select all from same split point as current/first selected"] : []),
			...candidates
				.filter((item) => !selected.has(item.id))
				.map(formatItem),
		];
		const title = selected.size > 0 ? `Return threads (${selected.size} selected)` : "Select thread to return/regroup";
		const choice = await ctx.ui.select(title, options);
		if (!choice) break;
		if (choice === "Done selecting") break;
		if (choice === "Select all from same split point as current/first selected") {
			const anchor = selected.values().next().value ?? candidates[0];
			for (const item of candidates) {
				if (item.sourceSessionFile === anchor.sourceSessionFile && item.sourceEntryId === anchor.sourceEntryId) selected.set(item.id, item);
			}
			continue;
		}
		const item = itemFromChoice(choice, candidates);
		if (item) selected.set(item.id, item);
	}
	return [...selected.values()];
}

async function openReturn(ctx: ExtensionCommandContext) {
	const queue = await loadQueue(ctx.cwd);
	const candidates = returnableItems(queue).sort((a, b) => a.createdAt.localeCompare(b.createdAt));
	if (candidates.length === 0) {
		ctx.ui.notify("No forked queue threads to return from", "info");
		return;
	}

	const selected = await selectReturnItems(ctx, candidates);
	if (selected.length === 0) return;

	const sourceSessionFile = selected[0].sourceSessionFile!;
	const sourceEntryId = selected[0].sourceEntryId!;
	const mismatched = selected.filter((item) => item.sourceSessionFile !== sourceSessionFile || item.sourceEntryId !== sourceEntryId);
	if (mismatched.length > 0) {
		const ok = await ctx.ui.confirm(
			"Different split points selected",
			"Some selected threads came from different source points. Return to the first selected thread's source point anyway?",
		);
		if (!ok) return;
	}

	ctx.ui.notify(`Summarizing ${selected.length} thread${selected.length === 1 ? "" : "s"}...`, "info");
	const summaries: Array<{ item: QueueItem; summary: string }> = [];
	for (const item of selected) {
		summaries.push({ item, summary: await summarizeThread(ctx, item) });
	}

	const regroupText = `Regroup after completed queue threads.\n\n${summaries
		.map(({ item, summary }) => `## ${item.title}\n${summary}`)
		.join("\n\n")}\n\nNext, help me regroup from these results. Identify what is done, what remains, and suggest the next planning or documentation step.`;

	await ctx.switchSession(sourceSessionFile, {
		withSession: async (sourceCtx) => {
			await sourceCtx.navigateTree(sourceEntryId, { label: "queue-return" });
			for (const { item, summary } of summaries) {
				await updateItem(sourceCtx.cwd, item.id, { status: "done", summary });
			}
			sourceCtx.ui.setEditorText(regroupText);
			sourceCtx.ui.notify("Returned to queue split point. Review/submit the regroup prompt when ready.", "info");
		},
	});
}

export default function queueExtension(pi: ExtensionAPI) {
	activePi = pi;

	pi.registerCommand("queue", {
		description: "Open queue picker or add a forkable queue item: /queue <task>",
		handler: async (args, ctx) => {
			const prompt = args.trim();
			if (!prompt) {
				await openQueue(ctx);
				return;
			}
			const item = await addItem(ctx, prompt);
			ctx.ui.notify(`Queued: ${item.title}`, "info");
		},
	});

	pi.registerCommand("split", {
		description: "Ask the model to split the last assistant message into coarse queue items",
		handler: async (_args, ctx) => {
			const text = getLastAssistantText(ctx);
			if (!text) {
				ctx.ui.notify("No assistant message found to split", "warning");
				return;
			}

			let items: string[];
			try {
				ctx.ui.notify("Proposing queue split...", "info");
				items = await generateSplitItems(text, ctx);
			} catch (err: any) {
				ctx.ui.notify(`Could not generate split: ${err?.message || err}`, "error");
				return;
			}
			if (items.length === 0) {
				ctx.ui.notify("Model did not propose any queue items", "warning");
				return;
			}

			const preview = items.map((item, i) => `${i + 1}. ${fallbackTitle(item)}`).join("\n");
			const ok = await ctx.ui.confirm("Split into queue items?", preview);
			if (!ok) return;

			for (const itemText of items) await addItem(ctx, itemText);
			ctx.ui.notify(`Queued ${items.length} items`, "info");
		},
	});

	pi.registerCommand("return", {
		description: "Summarize selected queue forks and return to their split point",
		handler: async (_args, ctx) => {
			await openReturn(ctx);
		},
	});

	pi.registerCommand("queue:prune", {
		description: "Remove completed queue items",
		handler: async (_args, ctx) => {
			const removed = await pruneDoneItems(ctx.cwd);
			ctx.ui.notify(`Pruned ${removed} done queue item${removed === 1 ? "" : "s"}`, "info");
		},
	});

	pi.registerCommand("queue:clear", {
		description: "Clear all queue items",
		handler: async (_args, ctx) => {
			const queue = await loadQueue(ctx.cwd);
			if (queue.items.length === 0) {
				ctx.ui.notify("Queue is already empty", "info");
				return;
			}
			const ok = await ctx.ui.confirm("Clear queue?", `Delete all ${queue.items.length} queue item${queue.items.length === 1 ? "" : "s"}?`);
			if (!ok) return;
			const removed = await clearQueue(ctx.cwd);
			ctx.ui.notify(`Cleared ${removed} queue item${removed === 1 ? "" : "s"}`, "info");
		},
	});
}
