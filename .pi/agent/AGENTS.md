# AGENTS.md

These instructions apply to all coding-agent work in this environment.

## Version control (git / jj)

- Agents MAY create branches and perform non-destructive VCS operations without asking
  (e.g. `git checkout -b`, `git add`, `git commit`; or with jj: `jj new`, `jj describe`,
  `jj commit`, `jj branch create`, `jj split`, `jj squash`).
- Agents MUST NOT push to remotes — `git push` / `jj git push` are human-only actions.
- Commit/describe messages follow git hygiene (verified conventions, see Git book / git-scm.com/docs/SubmittingPatches): summary ≤50 chars on line 1, imperative mood, capitalized, no trailing period, one logical change (no "and"/"also" padding); blank line, then body wrapped at ≤72 chars explaining what and why, not how. Conventional Commits types (`feat:`, `fix:`, ...) only when the project's AGENTS.md requires them.
- Agents MUST ask before destructive operations (e.g. `git reset --hard`, `git clean -f`,
  force operations, `jj abandon`, `jj op restore`, `jj gc`, deleting branches).

## Web search subagents

- Any subagent task that needs to make web search calls (research, fact-checking, fetching/verifying web content, searching GitHub) MUST run on a **gpt-5.6-luna** model at **high thinking**.
- The `web-researcher` agent is the DEFAULT for ALL web research and MUST be attempted first; the fallback below is used ONLY when it is genuinely unavailable.
- Concretely, use the `web-researcher` agent (model `openai-codex/gpt-5.6-luna`, thinking `high`), or pass `model: "openai-codex/gpt-5.6-luna"` and `thinking: "high"` explicitly when spawning web-searching subagents.
- Do NOT use the bare model name `gpt-5.6-luna` — it resolves to the opencode-go provider, which does not support web search. Always qualify it as `openai-codex/gpt-5.6-luna`.
- Web-research subagents must be read-only: they search and report; they do not modify the repository.

### Fallback: local-tool research (ONLY when luna is unavailable)

This is NOT the default. Always try the `web-researcher` agent (`openai-codex/gpt-5.6-luna`,
high thinking) first; the local-tool fallback below is used ONLY when that is genuinely
unavailable (e.g. the current model does not support native web search, like
opencode-go/deepseek-v4-flash, and no luna-backed agent can be spawned). When in doubt,
try luna first — do not silently substitute the fallback.

- Fetch pages: `curl -sL "<url>"` (add `-A "<desktop UA>"` if a site blocks the default UA)
- GitHub: `gh search repos|code|issues "<query>"`, `gh repo view <owner/repo>`,
  `gh api <endpoint>` (e.g. `gh api "search/code?q=<query>"`)
- Raw files/docs: `curl -sL https://raw.githubusercontent.com/<owner>/<repo>/<branch>/<path>`
  (prefer authenticated `gh api` — unauthenticated raw.githubusercontent.com is often rate-limited)
- HTML→text: `pandoc -f html -t plain` or `lynx -dump` if installed; JSON via `jq` if installed
- Search-engine fallback: `curl -sL "https://html.duckduckgo.com/html/?q=<query>"` and parse
  the result links
- Same constraints as subagent research: read-only; never write to the repo (artifacts only
  under `.pi-subagents/`); cite source URLs in reports; never put credentials in URLs.

## Generating a project's initial AGENTS.md

When a project has no AGENTS.md (new or existing repo), generate it with the **ai-init** skill:

- Run the skill: `pi /skill:ai-init` or just ask the agent to "initialize the project / generate the AGENTS.md".
- The skill flow: inspect the repository (never guess what files already decide) → ask the user
  interactive questions with the `ask` tool (select/confirm/input dialogs) → optionally research
  the stack with `web-researcher`
  (`openai-codex/gpt-5.6-luna`, high thinking) → write AGENTS.md from the skill's template and
  the generalized structure reference → optionally scaffold the project (`cargo init`, `justfile`,
  `.gitignore`) when the user confirms.
- Ask only what the repo cannot answer: purpose, toolchain, build/test/lint/format commands,
  monorepo?, generated files, critical constraints, subagent usage, whether to scaffold now.
  Batch into one `ask` call, prefer `select` over `input`, max ~10 questions.
- Keep the root file 50–150 lines; exact commands in fenced code blocks; critical constraints
  (MUST/MUST NOT/ALWAYS) near the top; link README/CONTRIBUTING/docs instead of duplicating them.
- After generating: add `.pi-subagents/` and build artifacts (`/target/` for Rust) to `.gitignore`;
  keep the file in sync when commands, structure, or generated-file workflows change.
- For monorepos, prefer a root file plus small nested `AGENTS.md` files per subtree over one large file.
- Never put secrets, credentials, or machine-specific paths in AGENTS.md.
