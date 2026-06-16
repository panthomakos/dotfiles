import { existsSync, readFileSync } from "node:fs";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import { randomUUID } from "node:crypto";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

function createHandoffPath(): string {
  return `/tmp/pi-handoff-${randomUUID()}.md`;
}

function readHandoffPrompt(): string {
  const path = join(homedir(), ".pi/agent/prompts/handoff.md");
  return readFileSync(path, "utf8");
}

function buildHandoffMessage(args: string, handoffPath: string): string {
  const focus = args.trim();
  return `${readHandoffPrompt()}

Additional instructions for this /carry invocation:
- Use this preselected conflict-resistant temporary handoff path: \`${handoffPath}\`.
- Save the handoff to exactly that path, overwriting any existing file.
- When finished, briefly report the saved path.
${
  focus
    ? `- Scope and tailor the handoff toward this next-session focus: ${focus}. Include only the parts of the session relevant to that focus, plus any essential dependencies or caveats.`
    : ""
}`;
}

function buildKickoffMessage(args: string, handoffPath: string): string {
  const focus = args.trim();
  return `Continue from the handoff at \`${handoffPath}\`.

First, read that file. Treat it as the authoritative compressed context from the previous session. Then continue the work.${focus ? `\n\nNext-session focus: ${focus}` : ""}`;
}

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

const QUEUE_VERSION = 1;

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

function makeQueueId(): string {
  return `q_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}

function shorten(text: string, max = 80): string {
  const compact = text.replace(/\s+/g, " ").trim();
  return compact.length <= max ? compact : `${compact.slice(0, max - 1)}…`;
}

async function addQueueItem(ctx: ExtensionCommandContext, prompt: string, title: string): Promise<QueueItem> {
  const queue = await loadQueue(ctx.cwd);
  const timestamp = new Date().toISOString();
  const item: QueueItem = {
    id: makeQueueId(),
    title,
    prompt: prompt.trim(),
    sourceSessionFile: ctx.sessionManager.getSessionFile(),
    sourceSessionId: ctx.sessionManager.getSessionId(),
    sourceEntryId: ctx.sessionManager.getLeafId() ?? undefined,
    status: "pending",
    createdAt: timestamp,
    updatedAt: timestamp,
  };
  queue.items.push(item);
  await saveQueue(ctx.cwd, queue);
  return item;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForHandoffCompletion(
  ctx: ExtensionCommandContext,
  handoffPath: string,
  timeoutMs = 120_000,
): Promise<boolean> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (existsSync(handoffPath) && ctx.isIdle()) return true;
    await sleep(500);
  }
  return existsSync(handoffPath) && ctx.isIdle();
}

export default function carryExtension(pi: ExtensionAPI) {
  pi.registerCommand("carry", {
    description: "Create a handoff, start a fresh session, and continue from it",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const handoffPath = createHandoffPath();
      ctx.ui.notify(`Writing handoff to ${handoffPath}...`, "info");
      pi.sendUserMessage(buildHandoffMessage(args, handoffPath));

      // sendUserMessage starts the turn on the next tick; yield before waiting or
      // waitForIdle can return while the agent is still technically idle.
      await sleep(100);
      await ctx.waitForIdle();

      if (!(await waitForHandoffCompletion(ctx, handoffPath))) {
        ctx.ui.notify(`Handoff was not completed at ${handoffPath}; not starting a new session.`, "warning");
        return;
      }

      const parentSession = ctx.sessionManager.getSessionFile();
      await ctx.newSession({
        parentSession,
        withSession: async (newCtx) => {
          await newCtx.sendUserMessage(buildKickoffMessage(args, handoffPath));
        },
      });
    },
  });

  pi.registerCommand("carry:queue", {
    description: "Create a handoff and add its continuation prompt to /queue",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const handoffPath = createHandoffPath();
      ctx.ui.notify(`Writing handoff to ${handoffPath}...`, "info");
      pi.sendUserMessage(buildHandoffMessage(args, handoffPath));

      // sendUserMessage starts the turn on the next tick; yield before waiting or
      // waitForIdle can return while the agent is still technically idle.
      await sleep(100);
      await ctx.waitForIdle();

      if (!(await waitForHandoffCompletion(ctx, handoffPath))) {
        ctx.ui.notify(`Handoff was not completed at ${handoffPath}; not adding a queue item.`, "warning");
        return;
      }

      const title = args.trim() ? `Carry: ${shorten(args.trim(), 70)}` : "Carry from handoff";
      const item = await addQueueItem(ctx, buildKickoffMessage(args, handoffPath), title);
      ctx.ui.notify(`Queued: ${item.title}`, "info");
    },
  });
}
