/**
 * ai-init extension — interactive `ask` tool.
 *
 * Registers a single `ask` tool that lets the agent prompt the user
 * interactively with the harness's UI hooks (ctx.ui.select / confirm /
 * input / editor). Questions are asked one at a time, blocking until the
 * user answers. Designed for the ai-init skill, but usable by any agent
 * that needs interactive clarification.
 *
 * Non-interactive modes (print/json/rpc without UI) return a graceful
 * fallback: the questions are listed in the tool result so the agent can
 * ask them in plain text instead.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai";

interface QuestionOption {
	label: string;
	description?: string;
}

interface Question {
	id: string;
	kind: "select" | "confirm" | "input" | "editor";
	prompt: string;
	options?: QuestionOption[];
	allowOther?: boolean;
	placeholder?: string;
	defaultText?: string;
}

interface Answer {
	id: string;
	kind: Question["kind"];
	question: string;
	answer: string | null;
	cancelled: boolean;
}

const QuestionOptionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option" }),
	description: Type.Optional(Type.String({ description: "Optional description shown below the label" })),
});

const QuestionSchema = Type.Object({
	id: Type.String({ description: "Unique short identifier for this question, e.g. 'package_manager'" }),
	kind: StringEnum(["select", "confirm", "input", "editor"] as const, {
		description: "select = pick one option (arrow keys), confirm = yes/no, input = single line, editor = multi-line",
	}),
	prompt: Type.String({ description: "The full question text shown to the user" }),
	options: Type.Optional(Type.Array(QuestionOptionSchema, {
		description: "Required for kind=select; ignored otherwise",
	})),
	allowOther: Type.Optional(Type.Boolean({
		description: "For kind=select: also offer a 'Type something.' free-text option (default true)",
	})),
	placeholder: Type.Optional(Type.String({ description: "Placeholder for kind=input" })),
	defaultText: Type.Optional(Type.String({ description: "Prefilled text for kind=editor" })),
});

const AskParams = Type.Object({
	questions: Type.Array(QuestionSchema, {
		description: "Questions to ask, in order. Keep to at most ~10; each is shown one at a time.",
	}),
});

export default function aiInitAsk(pi: ExtensionAPI) {
	pi.registerTool({
		name: "ask",
		label: "Ask User",
		description:
			"Ask the user one or more questions interactively (select, confirm, input, editor dialogs). " +
			"Use when you need decisions or facts from the user to proceed — e.g. project setup choices, " +
			"preferences, or anything you cannot infer from the repository. Batch related questions into a single call.",
		promptSnippet: "Interactively ask the user questions with the ask tool when you need their input.",
		promptGuidelines: [
			"Use ask when you need a decision or fact from the user that the repository cannot answer.",
			"Batch related questions into one ask call; do not ask the same thing twice.",
			"Prefer kind=select with concrete options over kind=input; only ask what matters.",
		],
		parameters: AskParams,
		executionMode: "sequential",

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const questions = (params.questions ?? []) as Question[];

			if (!ctx.hasUI) {
				const listed = questions
					.map((q, i) => {
						if (q.kind === "select") {
							const opts = (q.options ?? []).map((o) => o.label).join(", ");
							return `${i + 1}. ${q.prompt}  [options: ${opts}]`;
						}
						if (q.kind === "confirm") return `${i + 1}. ${q.prompt}  [yes/no]`;
						return `${i + 1}. ${q.prompt}`;
					})
					.join("\n");
				return {
					content: [
						{
							type: "text",
							text:
								`Interactive UI is not available in this mode (${ctx.mode}). ` +
								`Ask the user these questions in your next message and wait for their answers before continuing:\n${listed}`,
						},
					],
					details: { answers: [], fallback: true } as { answers: Answer[]; fallback: boolean },
				};
			}

			const answers: Answer[] = [];
			for (const q of questions) {
				if (q.kind === "confirm") {
					const ok = await ctx.ui.confirm(q.prompt, "Confirm?");
					answers.push({
						id: q.id,
						kind: q.kind,
						question: q.prompt,
						answer: ok ? "yes" : "no",
						cancelled: false,
					});
					continue;
				}

				if (q.kind === "input") {
					const value = await ctx.ui.input(q.prompt, q.placeholder ?? "");
					answers.push({
						id: q.id,
						kind: q.kind,
						question: q.prompt,
						answer: value ?? null,
						cancelled: value === undefined,
					});
					continue;
				}

				if (q.kind === "editor") {
					const value = await ctx.ui.editor(q.prompt, q.defaultText ?? "");
					answers.push({
						id: q.id,
						kind: q.kind,
						question: q.prompt,
						answer: value ?? null,
						cancelled: value === undefined,
					});
					continue;
				}

				// kind === "select"
				const allowOther = q.allowOther !== false;
				const labels = (q.options ?? []).map((o) => o.label);
				if (labels.length === 0) {
					answers.push({ id: q.id, kind: q.kind, question: q.prompt, answer: null, cancelled: true });
					continue;
				}
				const choice = await ctx.ui.select(q.prompt, allowOther ? [...labels, "Type something."] : labels);
				if (choice === undefined) {
					answers.push({ id: q.id, kind: q.kind, question: q.prompt, answer: null, cancelled: true });
					continue;
				}
				if (choice === "Type something.") {
					const custom = await ctx.ui.input(q.prompt, "");
					answers.push({
						id: q.id,
						kind: q.kind,
						question: q.prompt,
						answer: custom ?? null,
						cancelled: custom === undefined,
					});
					continue;
				}
				answers.push({ id: q.id, kind: q.kind, question: q.prompt, answer: choice, cancelled: false });
			}

			const lines = answers.map(
				(a, i) => `${i + 1}. ${a.question}\n   → ${a.cancelled ? "(cancelled)" : a.answer}`,
			);
			return {
				content: [{ type: "text", text: `Answers:\n${lines.join("\n")}` }],
				details: { answers, fallback: false } as { answers: Answer[]; fallback: boolean },
			};
		},
	});
}
