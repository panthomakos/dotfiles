import type { AssistantMessage, Model } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function fmtTokens(n: number | null | undefined): string {
  if (n == null || !Number.isFinite(n)) return "?";
  if (n < 1000) return String(Math.round(n));
  if (n < 1_000_000) return `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`;
  return `${(n / 1_000_000).toFixed(1)}m`;
}

function fmtPct(n: number | null | undefined): string {
  if (n == null || !Number.isFinite(n)) return "?%";
  return `${Math.round(n)}%`;
}

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh";
const THINKING_LEVELS: ThinkingLevel[] = ["off", "minimal", "low", "medium", "high", "xhigh"];

function getSupportedEfforts(model: Model<any> | undefined): ThinkingLevel[] {
  if (!model?.reasoning) return ["off"];
  return THINKING_LEVELS.filter((level) => model.thinkingLevelMap?.[level] !== null);
}

function getEffortLabel(model: Model<any> | undefined, level: ThinkingLevel): string | undefined {
  if (!model?.reasoning) return undefined;
  const mapped = model.thinkingLevelMap?.[level];
  return mapped ?? level;
}

export default function (pi: ExtensionAPI) {
  let currentModel: Model<any> | undefined;

  function getAvailableEfforts(): ThinkingLevel[] {
    return getSupportedEfforts(currentModel);
  }

  pi.registerCommand("effort", {
    description: "Select reasoning effort for thinking-capable models",
    getArgumentCompletions: (prefix: string) => {
      const items = getAvailableEfforts().map((level) => ({
        value: level,
        label: level,
        description: getEffortLabel(currentModel, level) ?? "reasoning effort",
      }));
      const needle = prefix.toLowerCase();
      const filtered = items.filter((item) =>
        item.value.toLowerCase().includes(needle) || item.description.toLowerCase().includes(needle),
      );
      return filtered.length ? filtered : null;
    },
    handler: async (args, ctx) => {
      currentModel = ctx.model as Model<any> | undefined;
      const levels = getAvailableEfforts();

      if (!currentModel?.reasoning || levels.length === 0 || (levels.length === 1 && levels[0] === "off")) {
        ctx.ui.notify("Current model does not support reasoning effort", "warning");
        return;
      }

      let selected: ThinkingLevel | undefined;
      const requested = args.trim().toLowerCase();
      if (requested) {
        selected = levels.find((level) => {
          const effort = getEffortLabel(currentModel, level)?.toLowerCase();
          return level === requested || effort === requested;
        });
        if (!selected) {
          ctx.ui.notify(`Invalid reasoning effort "${args}". Available: ${levels.join(", ")}`, "warning");
          return;
        }
      } else {
        selected = (await ctx.ui.select("Reasoning effort", levels)) as ThinkingLevel | undefined;
        if (!selected) return;
      }

      pi.setThinkingLevel(selected);
      ctx.ui.notify(`Reasoning effort: ${getEffortLabel(currentModel, selected)}`, "info");
    },
  });

  pi.on("model_select", async (event) => {
    currentModel = event.model as Model<any>;
  });

  pi.on("session_start", async (_event, ctx) => {
    currentModel = ctx.model as Model<any> | undefined;
    if (!ctx.hasUI) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubBranch = footerData.onBranchChange(() => tui.requestRender());
      const interval = setInterval(() => tui.requestRender(), 2000);

      return {
        dispose() {
          unsubBranch();
          clearInterval(interval);
        },
        invalidate() {},
        render(width: number): string[] {
          let input = 0;
          let output = 0;
          let cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              const message = entry.message as AssistantMessage;
              input += message.usage?.input ?? 0;
              output += message.usage?.output ?? 0;
              cost += message.usage?.cost?.total ?? 0;
            }
          }

          const usage = ctx.getContextUsage();
          const ctxText = usage
            ? `ctx ${fmtPct(usage.percent)} ${fmtTokens(usage.tokens)}/${fmtTokens(usage.contextWindow)}`
            : "ctx ?";
          const left = theme.fg("dim", `${ctxText} · ↑${fmtTokens(input)} ↓${fmtTokens(output)} $${cost.toFixed(3)}`);

          const branch = footerData.getGitBranch();
          const branchStr = branch ? ` (${branch})` : "";
          const model = currentModel ?? (ctx.model as Model<any> | undefined);
          const modelText = model?.id || "no-model";
          const effort = getEffortLabel(model, pi.getThinkingLevel() as ThinkingLevel);
          const effortStr = effort ? ` • effort ${effort}` : "";
          const right = theme.fg("dim", `${modelText}${effortStr}${branchStr}`);

          const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
          return [truncateToWidth(left + pad + right, width)];
        },
      };
    });
  });
}
