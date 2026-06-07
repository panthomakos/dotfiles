import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const HANDOFF_PATH = "/tmp/pi-handoff.md";

function readHandoffPrompt(): string {
  const path = join(homedir(), ".pi/agent/prompts/handoff.md");
  return readFileSync(path, "utf8");
}

function buildHandoffMessage(args: string): string {
  const focus = args.trim();
  return `${readHandoffPrompt()}

Additional instructions for this invocation:
- Save the handoff to exactly \`${HANDOFF_PATH}\`, overwriting any existing file.
- When finished, briefly report the saved path.
${focus ? `- Tailor the handoff toward this next-session focus: ${focus}` : ""}`;
}

function buildKickoffMessage(args: string): string {
  const focus = args.trim();
  return `Continue from the handoff at \`${HANDOFF_PATH}\`.

First, read that file. Treat it as the authoritative compressed context from the previous session. Then continue the work.${focus ? `\n\nNext-session focus: ${focus}` : ""}`;
}

export default function carryExtension(pi: ExtensionAPI) {
  pi.registerCommand("carry", {
    description: "Create a handoff, start a fresh session, and continue from it",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      ctx.ui.notify(`Writing handoff to ${HANDOFF_PATH}...`, "info");
      pi.sendUserMessage(buildHandoffMessage(args));
      await ctx.waitForIdle();

      if (!existsSync(HANDOFF_PATH)) {
        ctx.ui.notify(`Handoff file was not found at ${HANDOFF_PATH}; starting the new session anyway.`, "warning");
      }

      const parentSession = ctx.sessionManager.getSessionFile();
      await ctx.newSession({
        parentSession,
        withSession: async (newCtx) => {
          await newCtx.sendUserMessage(buildKickoffMessage(args));
        },
      });
    },
  });
}
