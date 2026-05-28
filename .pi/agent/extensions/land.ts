import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const LAND_PROMPT = `Land the current work cleanly.

Goals:
- Inspect the repository state and understand all uncommitted changes.
- Clean up implementation code: remove dead/debug code, tighten names, simplify where reasonable, and keep changes focused.
- Clean up documentation: update docs that should change, remove stale notes/TODOs introduced by this work, and keep documentation concise and accurate.
- Run the full relevant test/quality suite for this repository. Discover the right commands from package/config/docs if needed. Include lint/typecheck/build/tests when applicable.
- Fix failures or regressions you find, then rerun the affected checks until clean.
- Review the final diff carefully.
- Commit the completed work in reasonable, reviewable chunks grouped by concern. Use clear commit messages. Do not commit unrelated files, secrets, generated noise, or local-only artifacts.

Constraints:
- Do not ask for confirmation before running normal tests/checks or creating commits unless the repository state is ambiguous or credentials/destructive actions are required.
- If there are pre-existing unrelated changes, preserve them and avoid including them in commits unless they are necessary for this landing task.
- Report the checks run and commit hashes at the end.`;

export default function landExtension(pi: ExtensionAPI) {
  let pendingLandInstructions: string | undefined;

  pi.registerCommand("land", {
    description: "Clean up, test, document, and commit current work in reviewable chunks",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const extra = args.trim();
      pendingLandInstructions = extra ? `${LAND_PROMPT}\n\nAdditional landing instructions from the user:\n${extra}` : LAND_PROMPT;

      // Keep the persistent user message small; the full landing playbook is injected
      // into the system prompt for this turn only, so /land behaves like an extension
      // command rather than a skill/prompt expansion that bloats future context.
      pi.sendUserMessage(extra ? `Land the current work. Extra instructions: ${extra}` : "Land the current work.");
    },
  });

  pi.on("before_agent_start", async (event) => {
    if (!pendingLandInstructions) return;
    const instructions = pendingLandInstructions;
    pendingLandInstructions = undefined;
    return { systemPrompt: `${event.systemPrompt}\n\n${instructions}` };
  });
}
