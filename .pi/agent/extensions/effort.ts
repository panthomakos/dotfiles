import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh";

const THINKING_LEVELS: ThinkingLevel[] = ["off", "minimal", "low", "medium", "high", "xhigh"];
const DEFAULT_THINKING_LEVEL: ThinkingLevel = "medium";

function agentDir(): string {
  return process.env.PI_CODING_AGENT_DIR || path.join(os.homedir(), ".pi", "agent");
}

function settingsPath(): string {
  return path.join(agentDir(), "settings.json");
}

function readSettings(): Record<string, unknown> {
  const file = settingsPath();
  if (!fs.existsSync(file)) return {};
  const text = fs.readFileSync(file, "utf8").trim();
  if (!text) return {};
  return JSON.parse(text) as Record<string, unknown>;
}

function writeSettings(settings: Record<string, unknown>): void {
  const file = settingsPath();
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(settings, null, 2)}\n`, "utf8");
}

function isThinkingLevel(value: string): value is ThinkingLevel {
  return (THINKING_LEVELS as string[]).includes(value);
}

function getDefaultThinkingLevel(): { exists: boolean; value: ThinkingLevel } {
  const settings = readSettings();
  const value = settings.defaultThinkingLevel;
  return {
    exists: typeof value === "string" && isThinkingLevel(value),
    value: typeof value === "string" && isThinkingLevel(value) ? value : DEFAULT_THINKING_LEVEL,
  };
}

function setDefaultThinkingLevel(level: ThinkingLevel): void {
  const settings = readSettings();
  settings.defaultThinkingLevel = level;
  writeSettings(settings);
}

function restoreDefaultThinkingLevel(snapshot: { exists: boolean; value: ThinkingLevel }): void {
  const settings = readSettings();
  if (snapshot.exists) {
    settings.defaultThinkingLevel = snapshot.value;
  } else {
    delete settings.defaultThinkingLevel;
  }
  writeSettings(settings);
}

type EffortScope = "session" | "default";

function parseEffortArgs(args: string): { scope: EffortScope; level?: ThinkingLevel; invalid?: string } {
  const parts = args.trim().split(/\s+/).filter(Boolean);
  const scope: EffortScope = parts[0] === "default" ? "default" : "session";
  const levelText = parts[0] === "default" || parts[0] === "session" ? parts[1] : parts[0];
  const extra = parts[0] === "default" || parts[0] === "session" ? parts[2] : parts[1];

  if (extra) return { scope, invalid: extra };
  if (!levelText) return { scope };
  if (!isThinkingLevel(levelText)) return { scope, invalid: levelText };
  return { scope, level: levelText };
}

async function selectLevel(title: string, current: ThinkingLevel, ctx: ExtensionCommandContext): Promise<ThinkingLevel | undefined> {
  const choice = await ctx.ui.select(
    title,
    THINKING_LEVELS.map((level) => (level === current ? `${level} (current)` : level)),
  );
  if (!choice) return undefined;
  const level = choice.split(" ", 1)[0];
  return isThinkingLevel(level) ? level : undefined;
}

export default function effortExtension(pi: ExtensionAPI) {
  async function setSessionEffort(requested: ThinkingLevel | undefined, ctx: ExtensionCommandContext) {
    const current = pi.getThinkingLevel() as ThinkingLevel;
    const level = requested ?? (await selectLevel("Session effort", current, ctx));
    if (!level) return;

    // Pi currently persists thinking-level changes to defaultThinkingLevel as a side effect.
    // Preserve and restore the default so /effort is session-local.
    const defaultSnapshot = getDefaultThinkingLevel();
    pi.setThinkingLevel(level);
    restoreDefaultThinkingLevel(defaultSnapshot);

    const effective = pi.getThinkingLevel();
    ctx.ui.notify(effective === level ? `Session effort: ${level}` : `Session effort: ${effective} (requested ${level})`, "info");
  }

  async function setDefaultEffort(requested: ThinkingLevel | undefined, ctx: ExtensionCommandContext) {
    const current = getDefaultThinkingLevel().value;
    const level = requested ?? (await selectLevel("Default effort", current, ctx));
    if (!level) return;

    setDefaultThinkingLevel(level);
    ctx.ui.notify(`Default effort: ${level}`, "info");
  }

  async function setEffort(args: string, ctx: ExtensionCommandContext) {
    const parsed = parseEffortArgs(args);
    if (parsed.invalid) {
      ctx.ui.notify("Usage: /effort [session|default] [off|minimal|low|medium|high|xhigh]", "warning");
      return;
    }

    if (parsed.scope === "default") {
      await setDefaultEffort(parsed.level, ctx);
    } else {
      await setSessionEffort(parsed.level, ctx);
    }
  }

  pi.registerCommand("effort", {
    description: "Set thinking/effort level: /effort high or /effort default high",
    getArgumentCompletions: (prefix: string) => {
      const parts = prefix.trimStart().split(/\s+/).filter(Boolean);
      const endsWithSpace = /\s$/.test(prefix);
      const current = endsWithSpace ? "" : parts.at(-1) ?? "";

      if (parts[0] === "default" || parts[0] === "session") {
        const items = THINKING_LEVELS.filter((level) => level.startsWith(current)).map((level) => ({ value: level, label: level }));
        return items.length > 0 ? items : null;
      }

      const items = ["session", "default", ...THINKING_LEVELS]
        .filter((item) => item.startsWith(current))
        .map((item) => ({ value: item, label: item }));
      return items.length > 0 ? items : null;
    },
    handler: setEffort,
  });
}
