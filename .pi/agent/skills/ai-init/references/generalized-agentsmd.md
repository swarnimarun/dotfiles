# Generalized AGENTS.md structure — reference

Synthesized from live research (July 2026): the agents.md open format, OpenAI Codex docs,
13 verified real-world AGENTS.md files (next.js, openai/codex, cloudflare/workers-sdk, biome,
openai-cookbook, openai-agents-python, cloudflare/agents, promptfoo, actual, gatekeeper,
deepagents, awesome-copilot, agentsmd/agents.md), and consumer-side docs (Cursor, Claude Code,
Gemini CLI, GitHub Copilot).

## Facts that shape the structure

- AGENTS.md is an open, plain-Markdown convention: "simple, open Markdown format", "no required
  fields or schema" (agents.md). No YAML frontmatter or section order is required for
  interoperability.
- Codex loads AGENTS.md hierarchically (root → nested); more-local files refine/override;
  system/user instructions outrank repo instructions. Cursor: root file only. Claude Code:
  CLAUDE.md. Gemini CLI: GEMINI.md. GitHub Copilot: nearest AGENTS.md wins.
- Length: root file ~50–150 lines; nested files ~20–80. Files >~300 lines waste context.
- Agents parse plain Markdown; use headings, bullets, fenced code blocks. Be explicit.

## Recommended section order (root file)

1. **# AGENTS.md** + scope — applies to the repo; nested files refine it.
2. **Critical constraints** (near top!) — MUST / MUST NOT / ALWAYS rules: secrets, generated
   files, validation gates, dependencies. High-risk rules belong early.
3. **Project overview** — 1–2 sentences: what it builds, stack, package manager. NOT the README.
4. **Repository structure** — map directories → responsibilities. Agents pick files/tests from this.
5. **Setup and prerequisites** — toolchain versions, package manager, bootstrap, env vars
   (names only, never values).
6. **Commands** — exact copy-pasteable: install, dev, build, check, test, one-test, lint,
   format. Note slow/network/destructive commands. This is the highest-value section.
7. **Architecture and boundaries** — layers, dependency direction, where new code belongs,
   generated vs hand-written. Concrete constraints over prose.
8. **Code style and conventions** — repo-specific only (naming, imports, error handling,
   unsafe/generated-file policy). Point to formatter/linter as authoritative.
9. **Testing** — where tests live, types, targeted-test command, what must change with
   behavior changes, how to investigate failures.
10. **Do / Don't** — concrete guardrails with preferred alternatives ("Don't edit generated
    files — regenerate with X").
11. **Git and pull requests** — branch/commit conventions, changesets/changelog, required checks.
12. **References** — link README/CONTRIBUTING/docs instead of copying them.
13. **Nested instructions** — index of nested AGENTS.md files and their scope.

## Recurring real-world sections (verified headings)

- next.js: `## Codebase structure`, `## Build Commands`, `## Testing`, `## Secrets and Env Safety`,
  `## Specialized Skills`, `## Development Anti-Patterns`
- cloudflare/workers-sdk: `## Project Overview`, `## Development Commands`, `## Testing Strategy`,
  `## Changesets`, `## Anti-Patterns`, `## Cloudflare Workers Specifics`
- biome: `## Evidence Rule`, `## Mandatory Requirements`, `## AI Assistance Disclosure`,
  `## Code Generation`, `## Quality Checklist`
- openai-agents-python: `## Policies & Mandatory Rules`, `## Git Worktree and Branch Safety`,
  `## Public API Compatibility`, `## Testing & Automated Checks`, `## Code Review Rules`
- cloudflare/agents: `## Nested AGENTS.md files`, `## Learned Workspace Facts`,
  `## Learned User Preferences`, `## Boundaries`
- promptfoo: `## Running Evaluations`, `## Security-Sensitive PRs`,
  `## Screenshots for Pull Requests`, `## Adversarial and Redteam Bias`, `## Documentation Testing`

Ideas worth borrowing: evidence requirements for claims; generated-file/changeset gates;
security boundaries; nested scopes; "learned facts" sections; fast-vs-slow validation split.

## Pitfalls / anti-patterns

- Policy dumps: long, stale, generic ("write clean code", "follow best practices").
- Stale commands (agents fail repeatedly and distrust the file).
- Duplicating README/CONTRIBUTING/docs; contradiction between nested files.
- Secrets, credentials, machine-specific paths — never.
- Vague words ("usually", "appropriate") without definitions.
- Instructions that override security boundaries or authorization.

## Writing rules (condensed)

Exact commands in fenced blocks → state working dirs → specific paths over prose → critical
rules early with MUST/MUST NOT/ALWAYS → separate defaults from exceptions → one canonical
command per task → explain non-obvious rules in one sentence → link to docs instead of copying →
keep nested files additive → review the file when commands/structure change.
