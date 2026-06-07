---
name: web-research
description: Research current, external, or web-based information; compare products, pricing, libraries, APIs, companies, docs, releases, issues, or news; and analyze content from URLs.
---

# Web Research

Use this skill when the user asks to research current, external, or web-based information; compare products, pricing, libraries, APIs, companies, docs, releases, issues, or news; or analyze content from one or more URLs.

## Workflow

1. If the user provides specific URLs, use `web_fetch` on those URLs first.
2. If the user asks a broad/current question, use `web_search` to find sources.
3. Prefer primary and high-quality sources: official docs, changelogs, specs, standards, vendor pages, GitHub repositories/issues, academic or government sources, and reputable publications.
4. Use `web_fetch` to inspect promising sources before making detailed claims. Do not rely only on search snippets for important facts.
5. Cross-check important or surprising claims against multiple sources when practical.
6. Track dates: distinguish current facts from old posts, archived docs, and stale examples.
7. In the final answer, include source URLs for important claims and mention uncertainty or source limitations.
8. Be concise unless the user asks for a deep research report.

## Tool Guidance

- Use `web_search` for default discovery. It calls the reusable `~/.pi/agent/bin/pi-web-search` CLI: Google curl first, then DuckDuckGo HTML fallback if Google returns JS-only/CAPTCHA/unparseable markup.
- Use `web_fetch` for direct source inspection and analysis. It calls the reusable `~/.pi/agent/bin/pi-web-fetch` CLI.
- For direct URLs, skip search unless additional context or corroboration is needed.
- Use `agent-browser` via bash only when normal fetch/search is insufficient: JS-heavy pages, clicking through interfaces, screenshots, forms, login/session workflows, or other interactive browser tasks.
