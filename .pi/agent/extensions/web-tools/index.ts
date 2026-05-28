import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const SEARCH_CLI = `${process.env.HOME}/bin/pi-web-search`;
const FETCH_CLI = `${process.env.HOME}/bin/pi-web-fetch`;
const DEFAULT_FETCH_CHARS = 50_000;
const MAX_FETCH_CHARS = 200_000;

function clampInt(value: unknown, fallback: number, min: number, max: number): number {
  const n = typeof value === "number" && Number.isFinite(value) ? Math.floor(value) : fallback;
  return Math.max(min, Math.min(max, n));
}

function parseJsonOutput(stdout: string, stderr: string) {
  const text = stdout.trim() || stderr.trim();
  if (!text) throw new Error("Tool produced no JSON output");
  return JSON.parse(text);
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web using ~/bin/pi-web-search. Defaults to Google curl first, with DuckDuckGo HTML fallback when Google returns JS-only/CAPTCHA/unparseable markup. No API key required.",
    promptSnippet: "Search the web using a reusable local CLI; Google-first with lightweight fallback, no API key required.",
    promptGuidelines: [
      "Use web_search when the user asks for current information, recent events, web research, product/pricing comparisons, or information not available in local files.",
      "After web_search, use web_fetch on promising result URLs before making detailed claims.",
      "Prefer official docs, primary sources, changelogs, specs, vendor pages, and reputable sources when selecting URLs from web_search results.",
      "Use agent-browser via bash only for complex interactive browsing tasks such as clicking, logging in, screenshots, JS-heavy pages, or form workflows; do not use agent-browser for default search.",
      "If web_search returns warnings that Google was unparseable and fallback was used, you may mention that if the search provider matters to the user.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      maxResults: Type.Optional(Type.Number({ description: "Number of results to return, 1-10", default: 5 })),
      provider: Type.Optional(Type.Union([
        Type.Literal("auto"),
        Type.Literal("google"),
        Type.Literal("ddg"),
      ], { description: "Search provider. auto tries Google curl first, then falls back to DuckDuckGo HTML.", default: "auto" })),
    }),
    async execute(_toolCallId, params, signal) {
      const maxResults = clampInt(params.maxResults, 5, 1, 10);
      const provider = params.provider ?? "auto";
      const result = await pi.exec(SEARCH_CLI, [
        params.query,
        "--limit", String(maxResults),
        "--provider", provider,
      ], { signal, timeout: 35_000 });

      const parsed = parseJsonOutput(result.stdout, result.stderr);
      if (result.code !== 0 || parsed.error || !parsed.results?.length) {
        throw new Error(JSON.stringify(parsed, null, 2));
      }

      return {
        content: [{ type: "text", text: JSON.stringify(parsed, null, 2) }],
        details: parsed,
      };
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: "Fetch a web page or text URL and extract readable text using ~/bin/pi-web-fetch.",
    promptSnippet: "Fetch a web page and return readable text using a reusable local CLI.",
    promptGuidelines: [
      "Use web_fetch when the user provides a URL or after web_search identifies sources worth reading.",
      "Use web_fetch results, not only web_search snippets, for detailed analysis or quotations.",
      "Mention the fetched source URL in the final answer when using web_fetch for web research.",
      "If web_fetch fails because a page requires JavaScript or interaction, use agent-browser via bash as a fallback.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "http(s) URL to fetch" }),
      maxChars: Type.Optional(Type.Number({ description: "Maximum characters to return, up to 200000", default: DEFAULT_FETCH_CHARS })),
    }),
    async execute(_toolCallId, params, signal) {
      const maxChars = clampInt(params.maxChars, DEFAULT_FETCH_CHARS, 1_000, MAX_FETCH_CHARS);
      const result = await pi.exec(FETCH_CLI, [
        params.url,
        "--max-chars", String(maxChars),
      ], { signal, timeout: 40_000 });

      const parsed = parseJsonOutput(result.stdout, result.stderr);
      if (result.code !== 0 || parsed.error) {
        throw new Error(JSON.stringify(parsed, null, 2));
      }

      return {
        content: [{ type: "text", text: parsed.text ?? "" }],
        details: { ...parsed, text: undefined },
      };
    },
  });

  pi.registerCommand("web-tools", {
    description: "Show web tools setup/status",
    handler: async (_args, ctx) => {
      const searchCheck = await pi.exec(SEARCH_CLI, ["pi coding agent", "--limit", "1"], { timeout: 20_000 }).catch((error) => ({ code: 1, stderr: String(error), stdout: "" }));
      const fetchCheck = await pi.exec(FETCH_CLI, ["https://example.com", "--max-chars", "1000"], { timeout: 20_000 }).catch((error) => ({ code: 1, stderr: String(error), stdout: "" }));
      const browserCheck = await pi.exec("agent-browser", ["--help"], { timeout: 5_000 }).catch((error) => ({ code: 1, stderr: String(error) }));
      const lines = [
        `web_search: ${searchCheck.code === 0 ? "enabled via pi-web-search (Google-first, fallback available)" : `problem: ${searchCheck.stderr || searchCheck.stdout}`}`,
        `web_fetch: ${fetchCheck.code === 0 ? "enabled via pi-web-fetch" : `problem: ${fetchCheck.stderr || fetchCheck.stdout}`}`,
        `agent-browser fallback: ${browserCheck.code === 0 ? "available for interactive/JS-heavy pages" : "not available"}`,
      ];
      ctx.ui.notify(lines.join("\n"), searchCheck.code === 0 && fetchCheck.code === 0 ? "success" : "warning");
    },
  });
}
