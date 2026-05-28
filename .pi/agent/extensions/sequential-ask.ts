import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const DEFAULT_INSTRUCTION = `

When you need information from the user before proceeding:
- Prefer asking only the single most important question.
- If you genuinely need multiple answers, call the ask_user_questions tool instead of writing a numbered list of questions in normal assistant text.
- Keep each question concise, include relevant context in the question itself, and wait for the tool result before continuing.`;

const QuestionSchema = Type.Object({
  id: Type.Optional(Type.String({ description: "Stable identifier for this question, e.g. scope or style" })),
  label: Type.Optional(Type.String({ description: "Short label shown in the dialog title" })),
  question: Type.String({ description: "The question to ask the user" }),
  defaultAnswer: Type.Optional(Type.String({ description: "Optional prefilled answer" })),
});

const AskQuestionsParams = Type.Object({
  intro: Type.Optional(Type.String({ description: "Short context shown before the first question" })),
  questions: Type.Array(QuestionSchema, { description: "Questions to ask one-by-one" }),
});

type AskQuestion = {
  id?: string;
  label?: string;
  question: string;
  defaultAnswer?: string;
};

type AskAnswer = {
  id: string;
  label: string;
  question: string;
  answer: string;
};

function normalizeQuestionText(text: string): string {
  return text
    .replace(/^\s*(?:[-*+]\s+|\d+[.)]\s+|Q\d*[:.)]\s*|Q:\s*)/i, "")
    .trim();
}

function extractQuestions(text: string): string[] {
  const lines = text
    .split(/\r?\n/)
    .map(normalizeQuestionText)
    .filter(Boolean);

  const lineQuestions = lines.filter((line) => line.includes("?") && !/^A\s*:/i.test(line));
  if (lineQuestions.length > 1) return lineQuestions;
  if (lineQuestions.length === 1 && text.trim().split(/\?\s+/).length <= 2) return lineQuestions;

  const inline = text
    .split(/(?<=\?)\s+/)
    .map(normalizeQuestionText)
    .filter((part) => part.includes("?"));
  return inline.length ? inline : lineQuestions;
}

function lastAssistantText(ctx: any): string | undefined {
  const branch = ctx.sessionManager.getBranch();
  for (let i = branch.length - 1; i >= 0; i--) {
    const entry = branch[i];
    const msg = entry?.type === "message" ? entry.message : undefined;
    if (msg?.role !== "assistant") continue;
    const text = msg.content
      ?.filter((c: any) => c.type === "text")
      .map((c: any) => c.text)
      .join("\n")
      .trim();
    if (text) return text;
  }
  return undefined;
}

async function askSequentially(ctx: any, questions: AskQuestion[], intro?: string): Promise<AskAnswer[] | null> {
  const answers: AskAnswer[] = [];

  if (intro && ctx.hasUI) ctx.ui.notify(intro, "info");

  for (let i = 0; i < questions.length; i++) {
    const q = questions[i];
    const id = q.id || `q${i + 1}`;
    const label = q.label || `Question ${i + 1}`;
    const title = `${label} (${i + 1}/${questions.length})`;
    const prompt = `${q.question}\n\nEnter your answer:`;

    const answer = await ctx.ui.editor(prompt.startsWith(title) ? prompt : `${title}\n\n${prompt}`, q.defaultAnswer || "");
    if (answer === undefined) return null;

    answers.push({
      id,
      label,
      question: q.question,
      answer: answer.trim(),
    });
  }

  return answers;
}

function answersMarkdown(answers: AskAnswer[]): string {
  return answers
    .map((a, i) => `Q${i + 1} (${a.id}): ${a.question}\nA${i + 1}: ${a.answer || "[blank]"}`)
    .join("\n\n");
}

export default function sequentialAsk(pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_user_questions",
    label: "Ask User Questions",
    description: "Ask the user one or more questions sequentially using interactive dialogs. Use instead of dumping multiple clarifying questions in a single assistant message.",
    promptSnippet: "Ask the user one or more clarifying questions one-by-one",
    promptGuidelines: [
      "Use ask_user_questions when you need multiple user answers; do not present a batch of clarifying questions in normal assistant text.",
      "Prefer one high-value clarifying question when possible; use ask_user_questions only when multiple answers are needed to proceed.",
    ],
    parameters: AskQuestionsParams,
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [{ type: "text", text: "Error: ask_user_questions requires interactive UI." }],
          details: { cancelled: true, answers: [] },
          isError: true,
        };
      }

      if (!params.questions.length) {
        return {
          content: [{ type: "text", text: "Error: no questions were provided." }],
          details: { cancelled: true, answers: [] },
          isError: true,
        };
      }

      const answers = await askSequentially(ctx, params.questions, params.intro);
      if (answers === null) {
        return {
          content: [{ type: "text", text: "User cancelled the question flow." }],
          details: { cancelled: true, answers: [] },
        };
      }

      return {
        content: [{ type: "text", text: answersMarkdown(answers) }],
        details: { cancelled: false, answers },
      };
    },
  });

  pi.registerCommand("ask", {
    description: "Answer questions one-by-one. With no args, extracts questions from the last assistant message.",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      if (!ctx.hasUI) {
        ctx.ui.notify("/ask requires interactive mode", "error");
        return;
      }

      const source = args.trim() || lastAssistantText(ctx);
      if (!source) {
        ctx.ui.notify("Usage: /ask <questions>, or run /ask after an assistant message with questions", "warning");
        return;
      }

      const extracted = extractQuestions(source);
      if (extracted.length === 0) {
        ctx.ui.notify("No questions found", "warning");
        return;
      }

      const answers = await askSequentially(
        ctx,
        extracted.map((question, i) => ({ id: `q${i + 1}`, label: `Question ${i + 1}`, question })),
        `Answering ${extracted.length} question${extracted.length === 1 ? "" : "s"} one-by-one`,
      );

      if (answers === null) {
        ctx.ui.notify("Cancelled", "info");
        return;
      }

      pi.sendUserMessage(`Here are my answers:\n\n${answersMarkdown(answers)}`);
    },
  });

  pi.on("before_agent_start", async (event) => {
    if (event.systemPrompt.includes("ask_user_questions tool instead")) return;
    return { systemPrompt: event.systemPrompt + DEFAULT_INSTRUCTION };
  });
}
