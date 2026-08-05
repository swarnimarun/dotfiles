---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Run it on the web-research model `openai-codex/gpt-6-luna` at `high` thinking (the pi Codex
subscription), i.e. the `web-researcher` agent or an explicit `model: "openai-codex/gpt-6-luna"`
override; fall back to `openai-codex/gpt-5.6-luna` only if `gpt-6-luna` is unavailable. See
`~/.pi/agent/AGENTS.md` for the global web-search rule and the local-tool fallback.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
