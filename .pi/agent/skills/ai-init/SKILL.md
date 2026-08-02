---
name: ai-init
description: Initializes a project with a repo-specific AGENTS.md (and optionally scaffolds the project itself). Inspects the repository, asks the user interactive questions with the ask tool (select/confirm/input dialogs), and writes AGENTS.md from the generalized structure plus templates in this skill. Use when a project has no AGENTS.md, when starting a new project, or when asked to "initialize the project", "generate the agents file", or "set up AGENTS.md".
---

# ai-init — initialize a project with AGENTS.md

Generate the initial `AGENTS.md` for a project (new or existing), optionally initialize the
project scaffold, using interactive questions to resolve anything the repository cannot tell you.

## Prerequisites

- The `ask` tool must be available (registered by the `ai-init` extension at
  `~/.pi/agent/extensions/ai-init.ts`). It uses the harness UI hooks
  (`ctx.ui.select / confirm / input / editor`) to ask you questions interactively.
- If `ask` is missing, tell the user to create that extension (or run `/reload`), and fall back
  to asking the questions in plain text in your reply, waiting for answers.

## Workflow

### 1. Inspect the repository (do not guess)

Run, in this order:

- `ls -la` at the repo root; then `git status` (if `.git/` exists) or `jj status` (if `.jj/` exists)
- Look for: `Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, `justfile`, `Makefile`,
  `README.md`, `CONTRIBUTING.md`, existing `AGENTS.md`, `.gitignore`, `docs/`, `.jj/` or `.git/`
  (the VCS is decided by whichever directory exists — do not ask about it if so)
- Read `README.md` (first ~50 lines) and any existing `AGENTS.md` or `justfile`

Note what is already decided by the repo (package manager, commands, structure) — do NOT ask
questions about things you can read from files.

### 2. Ask interactive questions (one batched `ask` call)

Ask only what inspection did not answer. Max ~10 questions, prefer `select` with concrete
options over `input`. Typical questions:

- Project purpose (one sentence) — `input` unless a README already states it
- Primary language / framework / toolchain version — `select` if ambiguous
- Build/test/lint/format commands — `input` (one question, comma-separated) unless a
  `justfile`/`Makefile`/`package.json` already defines them
- Is it a monorepo / workspace? — `confirm`
- Which VCS: jj (Jujutsu) or git? — `select` with options `jj` / `git`, unless inspection
  already shows a `.jj/` or `.git/` directory (that decides it); recommend jj for new projects
- Any generated files that must not be edited by hand (e.g. `dist/`, `target/`, bindings,
  lockfiles)? — `input`, skip if obvious
- Critical constraints (secrets policy, dependency policy, destructive commands)? — `confirm`
  to add the standard ones
- Use subagents for research/review in this project? — `confirm` (recommended: yes)
- Initialize the project scaffold now (`cargo init` / `justfile` / `.gitignore`)? — `confirm`

If the user cancels a question, use your best judgment and note the assumption in the AGENTS.md.

### 3. Optionally research conventions

If the stack or its conventions are unfamiliar, spawn a read-only research subagent first:

- Use the `web-researcher` agent — `model: "openai-codex/gpt-5.6-luna"`, `thinking: "high"`
  (mandatory for anything requiring web search; see `~/.pi/agent/AGENTS.md` for the global rule).
- Ask it for the stack's canonical build/test/lint commands and common conventions.
- If no search-capable model is available (e.g. current model is opencode-go/deepseek-v4-flash),
  do the research yourself with read-only local tools (`curl`, `gh`, raw.githubusercontent.com)
  and cite source URLs — see `~/.pi/agent/AGENTS.md` for the fallback rules. The `web-researcher`
  agent is the default and MUST be attempted first; fall back only if it is unavailable.
- Never let a research subagent write files.

### 4. Write AGENTS.md

- Base the file on `templates/AGENTS.md` (generic template) and the section ordering and
  rationale in `references/generalized-agentsmd.md`.
- Keep the root file 50–150 lines. Exact commands in fenced code blocks. Concrete file paths.
- Fill every TODO; delete TODO markers when done.
- Do NOT duplicate the README or CONTRIBUTING.md — link to them.
- Include: Critical constraints (MUST/MUST NOT/ALWAYS), Project overview, Repository structure,
  Setup, Commands, Architecture/boundaries, Code style, Testing, Git/PR, References,
  Nested instructions index.
- Write the Git/PR section for the chosen VCS. Agents MAY create branches and run
  non-destructive VCS operations, but MUST NOT push and MUST ask before destructive
  operations — AGENTS.md states this. For jj: working copy is a commit that auto-snapshots
  (no staging area), messages via `jj describe`, `.gitignore` controls what jj snapshots;
  allowed ops include `jj commit`, `jj describe`, `jj new`, `jj branch create`, `jj split`,
  `jj squash`. For git: usual branch/commit flow with the same push/destructive rules.
- Include commit-message hygiene in the Git/PR section (verified conventions: Git book,
  git-scm.com/docs/SubmittingPatches): summary ≤50 chars, imperative mood, capitalized,
  no trailing period, one logical change; blank line, then body wrapped at ≤72 chars
  explaining what and why, not how; Conventional Commits types only if the project
  requires them.
- Add a "Subagent conventions" section when the project uses subagents: web research MUST use
  `web-researcher` (`openai-codex/gpt-5.6-luna`, high thinking); research/review agents are
  read-only; one writer at a time; `.pi-subagents/` artifacts are gitignored.

### 5. Initialize the project (only if the user confirmed)

- Rust: `cargo init` (binary unless told otherwise)
- VCS: if the user chose jj and no `.jj/` exists yet: `jj git init` (jj with a git backing
  store — existing `.gitignore` is honored by jj, keep it). If git: `git init -b main`.
- `justfile` with thin recipes wrapping cargo: `setup`, `build`, `check`, `test`, `lint`
  (`cargo clippy --all-targets -- -D warnings`), `fmt` (`cargo fmt`), `run`
- `.gitignore`: `/target/`, `.pi-subagents/`, `.env*`, `.DS_Store`
- Keep AGENTS.md commands in sync with whatever you scaffold.
- For jj, optionally `jj describe -m "<initial scaffold message>"` on the first snapshot.

### 6. Validate before finishing

- No secrets, credentials, or machine-specific paths in AGENTS.md
- Every command in AGENTS.md matches the actual project (or is marked TODO if the scaffold
  is not yet built)
- No duplicated README/CONTRIBUTING content
- Markdown is well-formed; nested-file references point at files that exist (or TODO)

## References

- [Generalized AGENTS.md structure and rationale](references/generalized-agentsmd.md)
- [AGENTS.md template](templates/AGENTS.md)
