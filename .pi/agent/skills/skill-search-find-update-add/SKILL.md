---
name: skill-search-find-update-add
description: Search the Cursor PStack and Matt Pocock skills repositories for useful new or changed skills, compare them with the local Codex and Pi custom skills, and propose additions or updates for approval.
---

# Search, find, update, and add skills

Use this skill only when the user explicitly asks to search the upstream skill repositories, check for updates, or add a skill.

The tracked upstream sources are:

- PStack: `https://github.com/cursor/plugins.git`, skills under `pstack/skills/`
- Matt Pocock: `https://github.com/mattpocock/skills.git`, skills under `skills/`

Keep temporary clones outside the tracked skill trees, such as `/private/tmp/skill-search-find-update-add/`. Fetch the current default branch before comparing. Do not rely on an old cached clone.

## Find candidates

Inventory upstream directories containing `SKILL.md` and compare them with these local custom roots:

- Codex: `~/.codex/skills/`, excluding `.system/`
- Pi main agent: `~/.pi/agent/skills/`
- Pi subagents: `~/.pi/agents/skills/`

For each matching skill, compare the complete bundle: `SKILL.md`, `agents/`, `references/`, `resources/`, `playbooks/`, `scripts/`, and other files beside the entrypoint. Report whether it is new, unchanged, or changed, and list missing local companion files. Ignore plugin caches, curated caches, npm packages, generated files, auth files, sessions, and unrelated repositories.

Filter recommendations by the user's current request. Do not recommend importing the entire upstream catalog. Prefer a small set of skills whose description and files directly improve that request. Flag skills that mention Cursor-only paths, unavailable tools, hard-coded model names, external services, or destructive actions.

## Approval gate

Before changing any installed skill, show a compact table with:

1. upstream repository and skill path;
2. local destinations;
3. new versus changed status;
4. the reason it is useful for the user's request;
5. compatibility or migration concerns.

Ask the user which candidates to add or update. Treat silence as no approval. Never add or update a skill merely because it exists upstream.

## Apply approved changes

For each approved candidate:

- Copy the complete upstream bundle to `~/.codex/skills/<skill-name>/`, `~/.pi/agent/skills/<skill-name>/`, and `~/.pi/agents/skills/<skill-name>/`.
- Preserve local files only when the user declines an upstream replacement. If an existing `SKILL.md` differs, show the relevant diff and ask whether to replace it; do not silently overwrite local adaptations.
- Keep names lowercase, numeric, and hyphen-separated. Adapt only environment-specific paths, tool names, and invocation metadata that are required for Codex or Pi, and record those adaptations in the response.
- Do not copy plugin manifests, npm packages, credentials, caches, build output, or repository-level configuration into a skill directory.
- Do not change `~/.gitignore` during an ordinary update. The custom Codex and Pi skill roots are already the sync scope; expand it only when the user explicitly requests that.

## Validate

After approved changes, validate every affected `SKILL.md` front matter, confirm all relative Markdown links and referenced companion files exist, and inspect the final file list for secrets or generated artifacts. Run the available skill validator; if its runtime dependency is unavailable, use an independent YAML parser and report that limitation. Re-run the comparison so Codex and both Pi roots agree for every approved skill.

End with the upstream commit IDs, the approved skills changed, the destinations updated, and any candidates the user declined or that require manual adaptation.
