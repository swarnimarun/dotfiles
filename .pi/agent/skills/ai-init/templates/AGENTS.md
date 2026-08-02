# AGENTS.md

Instructions for AI coding agents working in this repository. Read this file before making changes.

## Scope

Applies to the whole repository. More specific rules live in nested `AGENTS.md` files (see [Nested instructions](#nested-instructions)); when instructions conflict, the most specific file wins.

## Critical constraints

- MUST NOT commit secrets, credentials, tokens, or local environment files (e.g. `.env.local`).
- MUST NOT edit generated files, lockfiles, or vendored code by hand — always regenerate through the tool that owns them.
- MUST run the validation commands in [Commands](#commands) before requesting review.
- MUST NOT add dependencies without explaining why.
- MUST NOT weaken or delete tests to make them pass.
- ALWAYS keep diffs focused on the task at hand.

## Project overview

TODO: one short paragraph — what this project builds, the primary language/framework, and the package manager. Do not copy the README; agents need orientation, not marketing.

## Repository structure

TODO: map important directories to their responsibilities, e.g.:

- `src/` — application source
- `test/` or `tests/` — tests and fixtures
- `docs/` — design and architecture documentation
- `scripts/` — maintenance and automation scripts

## Setup and prerequisites

TODO: exact bootstrap steps, e.g.:

- Runtime version: see `.nvmrc` / `.tool-versions` / `rust-toolchain.toml`
- Install dependencies: `pnpm install`
- Copy `.env.example` to `.env.local`; never commit local environment files

## Commands

Exact, copy-pasteable commands. State the working directory when it is not the repository root.

TODO: replace with the project's real commands.

- Install: `pnpm install`
- Development: `pnpm dev`
- Unit tests: `pnpm test`
- One test: `pnpm test -- <path/to/file.test.ts>`
- Lint: `pnpm lint`
- Type-check: `pnpm typecheck`
- Build: `pnpm build`
- Format: `pnpm format`

Note which commands are slow, network-dependent, or require services/credentials.

## Architecture and boundaries

TODO: describe layers, dependency direction, data flow, and where new code belongs. Prefer concrete constraints over prose, e.g.:

- Business rules belong in the service layer, not in route handlers or UI components.
- `shared/` MUST NOT import from `api/` or `web/`.
- Public APIs are stable; changes require a migration note.

## Code style and conventions

Only repository-specific rules — do not restate generic language style. TODO: fill in, e.g.:

- Formatting is enforced by the formatter; run the format command rather than formatting manually.
- Strict typing; no `any`/`unwrap`/unsafe without justification.
- Import ordering and naming rules, if they differ from tool defaults.
- Error-handling and logging conventions.

## Testing

- Where tests live and which types exist (unit / integration / e2e).
- The targeted test command for a change area (see [Commands](#commands)).
- What must be updated when behavior changes (tests, fixtures, snapshots, baselines, docs).
- How to investigate a failing test; do not delete or weaken tests to make them pass.

TODO: fill in project specifics.

## Do / Don't

Concrete guardrails, paired with the preferred alternative where possible.

- Do add or update tests for behavior changes.
- Do run the targeted test before the full suite.
- Do preserve public API compatibility.
- Don't edit generated output directly — regenerate it.
- Don't commit secrets or local environment files.
- Don't add dependencies without approval.
- Don't make unrelated refactors in the same change.
- Don't push to remotes or run destructive VCS operations without asking — branch creation and non-destructive ops are fine.

## Git and pull requests

TODO: fill in if the project has conventions, e.g.:

- VCS is jj or git (decided by the ai-init questions / which of `.jj/` or `.git/` exists).
  For jj, say so explicitly and document the workflow: the working copy is a commit that
  auto-snapshots (no staging area), commit messages via `jj describe`, and `.gitignore`
  controls what jj snapshots. Agents MAY create branches and run non-destructive VCS
  operations (`jj commit`, `jj describe`, `jj new`, `jj branch create`, `jj split`,
  `jj squash`, `git add`, `git commit`, ...) but MUST NOT push (`jj git push` / `git push`)
  and MUST ask before destructive operations (`jj abandon`, `jj gc`, `git reset --hard`,
  `git clean -f`, ...).
- Branch naming conventions.
- Commit message hygiene (git and jj alike): summary ≤50 chars on line 1, imperative mood,
  capitalized, no trailing period, one logical change; blank line before the body; body
  wrapped at ≤72 chars explaining what and why, not how. Conventional Commits types
  (`feat:`, `fix:`, ...) only if the project requires them.
- Changelog / changeset requirements.
- Required checks before merge (lint, typecheck, tests, build).
- Anything about review scope or CI-only workflows.

## Subagent conventions

TODO: keep this section only if the project uses subagents, e.g.:

- Web research / anything requiring web search MUST use the `web-researcher` agent (`openai-codex/gpt-5.6-luna`, high thinking) — see `~/.pi/agent/AGENTS.md`.
- Fallback ONLY when the `web-researcher` agent is unavailable (never the default — attempt
  `web-researcher`/luna first): read-only local-tool research with the current model (`curl`,
  `gh`, raw.githubusercontent.com, DuckDuckGo HTML) — see `~/.pi/agent/AGENTS.md`.
- Research and review subagents are read-only: they search and report, they do not modify the repository.
- Keep one writer at a time for implementation work; use reviewers/validators as independent read-only passes.
- Subagent run artifacts live under `.pi-subagents/`, which is gitignored — do not commit them.

## References

Link to detailed documentation instead of duplicating it:

- `README.md` — human-facing overview and usage
- `CONTRIBUTING.md` — contribution workflow
- `docs/` — architecture decisions, API specs, troubleshooting

## Nested instructions

TODO: list nested `AGENTS.md` files once they exist, e.g.:

- `packages/api/AGENTS.md` — API-specific commands and rules
- `packages/web/AGENTS.md` — web-specific commands and rules

Nested files MUST only add or refine rules for their subtree; keep shared rules here.
