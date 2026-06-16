import { existsSync, readFileSync } from "node:fs";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type CommandInfo = {
  name: string;
  description?: string;
  source: "extension" | "prompt" | "skill";
  sourceInfo?: {
    path?: string;
    source?: string;
    scope?: string;
    origin?: string;
    baseDir?: string;
  };
};

type ResourceDoc = {
  name: string;
  path: string;
  description?: string;
  argumentHint?: string;
  bodyPreview?: string;
  scope?: string;
};

const HEADER_LINES = [
  "    ██████████████████████░ ",
  "    ▀▀▀▀▀██████▀▀██████▀▀░ ",
  "        ░█████  ░█████    ",
  "        ░█████  ░█████    ",
  "        ░█████  ░█████    ",
  "        ░█████  ░█████    ",
  "        ░█████  ░█████    ",
  "      ████████  ████████░ ",
  "      ▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀░ ",
  "    π coding agent        ",
];

function colorArtLine(theme: Theme, line: string): string {
  let out = "";
  for (const char of line) {
    if (char === "█" || char === "▀") out += theme.fg("accent", char);
    else if (char === "░") out += theme.fg("dim", char);
    else if (char === "π") out += theme.fg("accent", char);
    else out += char;
  }
  return out;
}

function centerAnsi(line: string, width: number): string {
  const pad = Math.max(0, Math.floor((width - visibleWidth(line)) / 2));
  return `${" ".repeat(pad)}${truncateToWidth(line, width)}`;
}

function renderPiHeader(theme: Theme, width: number): string[] {
  const art = HEADER_LINES.map((line, i) => {
    const colored = i === HEADER_LINES.length - 1
      ? theme.fg("muted", line).replace("π", theme.fg("accent", "π"))
      : colorArtLine(theme, line);
    return centerAnsi(colored, width);
  });

  const subtitle = centerAnsi(
    `${theme.fg("dim", "v" + VERSION)} ${theme.fg("muted", "·")} ${theme.fg("accent", "/h")} ${theme.fg("dim", "local help")}`,
    width,
  );
  return ["", ...art, subtitle, ""];
}

function parseFrontmatter(raw: string): { attrs: Record<string, string>; body: string } {
  const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!match) return { attrs: {}, body: raw };

  const attrs: Record<string, string> = {};
  for (const line of match[1].split(/\r?\n/)) {
    const kv = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!kv) continue;
    attrs[kv[1]] = kv[2].replace(/^['"]|['"]$/g, "").trim();
  }
  return { attrs, body: raw.slice(match[0].length) };
}

function firstMeaningfulLines(body: string, maxChars: number): string | undefined {
  const lines = body
    .split(/\r?\n/)
    .map((line) => line.trimEnd())
    .filter((line) => line.trim() && !line.trim().startsWith("---"));
  const joined = lines.join("\n").trim();
  if (!joined) return undefined;
  return joined.length <= maxChars ? joined : `${joined.slice(0, maxChars - 1).trimEnd()}…`;
}

function readResource(command: CommandInfo, maxChars: number): ResourceDoc {
  const path = command.sourceInfo?.path || "";
  let description = command.description;
  let argumentHint: string | undefined;
  let bodyPreview: string | undefined;

  if (path && existsSync(path)) {
    try {
      const { attrs, body } = parseFrontmatter(readFileSync(path, "utf8"));
      description = attrs.description || description;
      argumentHint = attrs["argument-hint"];
      bodyPreview = firstMeaningfulLines(body, maxChars);
    } catch {
      // Keep command metadata if the file cannot be read.
    }
  }

  return {
    name: command.name,
    path,
    description,
    argumentHint,
    bodyPreview,
    scope: command.sourceInfo?.scope,
  };
}

function formatResource(doc: ResourceDoc, prefix: string): string {
  const parts = [`### ${prefix}${doc.name}`];
  if (doc.argumentHint) parts[0] += ` ${doc.argumentHint}`;
  if (doc.description) parts.push(doc.description);
  if (doc.path) parts.push(`Path: ${doc.path}${doc.scope ? ` (${doc.scope})` : ""}`);
  if (doc.bodyPreview) parts.push("", doc.bodyPreview);
  return parts.join("\n");
}

function formatExtensionCommand(command: CommandInfo): string {
  const lines = [`### /${command.name}`];
  if (command.description) lines.push(command.description);
  if (command.sourceInfo?.path) lines.push(`Path: ${command.sourceInfo.path}${command.sourceInfo.scope ? ` (${command.sourceInfo.scope})` : ""}`);
  lines.push("Runs locally as an extension command; it does not expand into prompt text.");
  return lines.join("\n");
}

function groupByPath(commands: CommandInfo[]): Map<string, CommandInfo[]> {
  const grouped = new Map<string, CommandInfo[]>();
  for (const command of commands) {
    const key = command.sourceInfo?.path || "<unknown>";
    grouped.set(key, [...(grouped.get(key) || []), command]);
  }
  return grouped;
}

function buildHelp(pi: ExtensionAPI, args: string): string {
  const filter = args.trim().toLowerCase();
  const full = /\b(full|all|verbose)\b/.test(filter);
  const want = (section: string) => !filter || full || filter.includes(section);
  const previewChars = full ? 1800 : 700;

  const commands = (pi.getCommands() as CommandInfo[]).sort((a, b) => a.name.localeCompare(b.name));
  const extensionCommands = commands.filter((command) => command.source === "extension");
  const prompts = commands.filter((command) => command.source === "prompt").map((command) => readResource(command, previewChars));
  const skills = commands.filter((command) => command.source === "skill").map((command) => readResource(command, previewChars));

  const lines: string[] = [
    "# Pi local help (/h)",
    "",
    "This view is rendered by an extension command. It does not call the model, send a user message, append a session entry, or populate LLM context.",
    "",
    `Loaded: ${skills.length} skill commands · ${prompts.length} prompt templates · ${extensionCommands.length} extension commands`,
    "Tip: run `/h full`, `/h skills`, `/h prompts`, or `/h commands` for targeted output.",
  ];

  if (want("skill")) {
    lines.push("", "## Skills", "");
    lines.push(...(skills.length ? skills.map((doc) => formatResource(doc, "/")) : ["No skills loaded."]));
  }

  if (want("prompt")) {
    lines.push("", "## Prompt templates", "");
    lines.push(...(prompts.length ? prompts.map((doc) => formatResource(doc, "/")) : ["No prompt templates loaded."]));
  }

  if (want("command") || want("extension")) {
    lines.push("", "## Extension commands", "");
    if (!extensionCommands.length) {
      lines.push("No extension commands loaded.");
    } else {
      for (const [path, items] of groupByPath(extensionCommands)) {
        lines.push(`### ${path}`);
        for (const command of items) {
          lines.push(`- /${command.name}${command.description ? ` — ${command.description}` : ""}`);
        }
        lines.push("");
      }
      if (full) lines.push(...extensionCommands.map(formatExtensionCommand));
    }
  }

  lines.push("", "Note: built-in interactive commands such as /model and /settings are handled by Pi itself and are not included in pi.getCommands().");
  return lines.join("\n");
}

export default function helpHeaderExtension(pi: ExtensionAPI) {
  pi.registerCommand("h", {
    description: "Show detailed local help for loaded skills, prompts, and extension commands without adding context",
    getArgumentCompletions: (prefix: string) => {
      const items = ["full", "skills", "prompts", "commands"].map((value) => ({ value, label: value }));
      const filtered = items.filter((item) => item.value.startsWith(prefix.toLowerCase()));
      return filtered.length ? filtered : null;
    },
    handler: async (args, ctx) => {
      await ctx.waitForIdle();
      const text = buildHelp(pi, args);
      if (ctx.hasUI) {
        if (/\b(full|all|verbose|skills?|prompts?|commands?|extensions?)\b/i.test(args)) {
          await ctx.ui.editor("Pi help (/h) — local only; close with Escape", text);
        } else {
          const commands = (pi.getCommands() as CommandInfo[]).sort((a, b) => a.name.localeCompare(b.name));
          const extensionCommands = commands.filter((command) => command.source === "extension");
          const prompts = commands.filter((command) => command.source === "prompt");
          const skills = commands.filter((command) => command.source === "skill");
          ctx.ui.notify(
            `Local help: ${skills.length} skills · ${prompts.length} prompts · ${extensionCommands.length} extension commands. Use /h full, /h skills, /h prompts, or /h commands for the scrollable detail view.`,
            "info",
          );
        }
      } else {
        console.log(text);
      }
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setHeader((_tui, theme) => ({
      render(width: number): string[] {
        return renderPiHeader(theme, width);
      },
      invalidate() {},
    }));
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setHeader(undefined);
  });
}
