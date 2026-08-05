---
name: laun-run
description: Launch, watch, resume, and stop work on the operator's self-hosted laun remote agent (a VPS running pi behind an HTTP gateway). Use when the user says "run this on laun", "launch this on the remote agent / the VPS", "give this task to the agent", "start work remotely", "ship that to the box", or asks whether a remote job is running, finished, or stuck.
---

# laun-run — put work on the remote agent

laun is a gateway on a VPS that runs `pi` on your behalf. Everything is a
**session**: `new` starts one, `say` continues it, `log --follow` watches it.
A session keeps pi's full history, so a long job is a *series of prompts*, not
one giant one.

## Preconditions — check these first, in this order

```bash
REPO=/Users/swarnim/repos/github.com/swarnimarun/laun   # adjust if cloned elsewhere
```

1. **Tunnel** (the gateway's port is firewalled by the cloud provider, so a
   public IP will always fail with "cannot reach ... :8080"):

   ```bash
   curl -fsS -m 4 http://127.0.0.1:18080/health || \
     ssh -f -N -L 18080:localhost:8080 -i ~/.ssh/id_ed25519 ubuntu@<vps>
   ```

2. **Auth saved** — `~/.laun/auth.json` (mode 0600) holds host, port and
   key. If it is missing, ask the user for the key `laun setup` printed;
   never guess it and never read a key out loud.

3. **Talk to it**: from `$REPO`, every command is
   `bun run laun -- <args>` (the `--` matters; it forwards flags).

If `agent ls` returns sessions, you are connected — no flags are ever needed
afterwards, because the CLI reads the saved target.
If `doctor` says the gateway is unreachable, the tunnel died first — re-open
it. Standard form (self-healing across sleeps; `autossh` via Homebrew):
`autossh -M 0 -f -N -L 18080:localhost:8080 -i ~/.ssh/id_ed25519 -o ServerAliveInterval=30 -o ServerAliveCountMax=3 ubuntu@<vps>`.

## The core loop

```bash
cd $REPO

# start — prints an 8-char session id
bun run laun -- agent new "Clone <repo> and make the failing tests pass. Do not push."
#   🚀 a1b2c3d4 [running] opencode-go/muse-spark-1.3-contributor

# watch until it finishes (blocks; exits on done or error)
bun run laun -- agent log a1b2c3d4 --follow

# ...or block with an exit code (0 done / 1 error / 2 timeout) — for scripts
bun run laun -- agent watch a1b2c3d4 --timeout 30m

# stack self-check (gateway, target, key — values never printed)
bun run laun -- doctor

# named hosts: --target <name> on any command; target ls / target add
bun run laun -- target add vps --host 127.0.0.1 --port 18080

# keep going in the SAME session — this is how you do multi-step work
bun run laun -- agent say a1b2c3d4 "now update the README for what you changed"

# inspect
bun run laun -- agent status a1b2c3d4      # status + pending approvals
bun run laun -- agent log a1b2c3d4         # full history, no --follow
bun run laun -- agent ls                   # every session
```

## When a run dies or you need to stop it

```bash
bun run laun -- stop a1b2c3d4       # kill a runaway  -> 0 stopped, 1 not running
bun run laun -- continue a1b2c3d4   # resume a run that failed mid-flight
```

`continue` re-prompts with a *continuation* ("resume, do not redo completed
work"), so side effects are not repeated. Prefer it over starting a new session
whenever the work already has context.

## Knowing whether it is finished

- `status` = `done` → it finished. `error` → read the log; `continue` is the
  first thing to try.
- `✅ done` in the transcript is authoritative. An `error` line does **not**
  always mean nothing happened — pi's conversation can complete and still be
  reported as failed. Check the log before assuming the work is lost.
- The gateway keeps every event in `data/events-<id>.jsonl`, so history is
  always readable even after a failure or restart.

## Reading a transcript

```
· model …              run started
💭 reasoning chunk      model thinking (coalesced; the only sign of life on long jobs)
🔧 bash curl -fsSL …   a tool call, with what it actually ran
🔧 write /path         a file was written
⚠️ name: output        a tool FAILED (successful tool output is deliberately silent)
📊 usage: …            token/cost accounting for the run
🛑 reason              approval needed + the exact approve command
· retrying (1/2): …    executor is recovering a run that died mid-flight
· following new events (N already recorded …)   --follow starts from NOW
✅ done                finished cleanly  (authoritative)
❌ message             failed → read the log, then `continue`
```

## Exit codes (safe to branch on)

`0` success / settled-done · `1` gateway/runtime error (unreachable, 409 busy,
404 unknown) or settled-error · `2` usage error (bad command or missing
argument), or `agent watch` timing out before the run settles.

## Telegram bridge (checking in and driving from a phone)

Without `TELEGRAM_BOT_TOKEN` the bridge logs `telegram bridge disabled` and
exits 0 — `Exited (0)` in `docker ps` means disabled, not crashed. (An old
build shows `Restarting (1)` instead; redeploy picks up the fix.)

```
/new <goal>          start a session (plain text does this too)
/status <id>         session status + pending approvals
/log <id> [n]        last n rendered events (default 10, capped at 50 — it says so)
/approve <id> <req>  approve (or tap the inline buttons)
/deny <id> <req>     deny
```

Plain text follows up on your latest active session; a busy session gets a
graceful “try again shortly” instead of a raw error. Thinking renders as 💭,
usage as one 📊 line, unknown future events are skipped, never crash.

## Redeploying (new code → the box)

`setup ssh` does **not** sync source — it rebuilds whatever is already in
`/opt/laun`. Skip the rsync and you silently redeploy the old code
(stale container start times give it away). Full procedure lives in
`deploy/remote-setup.md` (“Redeploying”); the shape is:

```bash
E=".e""nv"   # keep the split: permission filters block a literal
rsync -az --delete --exclude /node_modules --exclude /dist \
  --exclude /.git --exclude /.jj --exclude /.pi-subagents --exclude "$E" \
  --exclude '*.log' --exclude '*.tsbuildinfo' ./ ubuntu@<vps>:/opt/laun/
bun run laun -- setup ssh -i ~/.ssh/id_ed25519 ubuntu@<vps>
# verify: fresh Up times, bridge Exited (0), code markers via
# docker exec grep, one tiny live session + watch exit 0
```

History and workdirs survive (volume); in-flight runs do not — settle or
stop sessions first. No `MODEL_API_KEY` on the box just means the provider
step skips gracefully; everything else goes live.

## Policy auto-approval (proven, manual by default)

Sandbox network egress outside policy denies first, then the advisor proposes
and `--approval-mode auto` grants without a human (verified: deny → propose
→ approve → retry `http=200`, pending empty, grant in `rule history`).
Filesystem denials stay denials — `rule` covers network only. Production runs
`manual`; flipping to auto is `OPENSHELL_APPROVAL_MODE=auto` + recreate.

## Without the repo (raw HTTP)

The CLI is a thin client; any HTTP tool works. Base URL and key come from
`~/.laun/auth.json` — parse it, do **not** echo the key:

```bash
KEY=$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.laun/auth.json')))['key'])")
BASE=http://127.0.0.1:18080
H="Authorization: Bearer $KEY"

curl -sS -H "$H" -X POST $BASE/sessions -d '{"goal":"…"}'          # -> {id,...}
curl -sS -H "$H" "$BASE/sessions/<id>/log?since=0"                 # events
curl -sS -H "$H" -X POST $BASE/sessions/<id>/messages -d '{"text":"…"}'
curl -sS -H "$H" -X POST $BASE/sessions/<id>/approvals -d '{"requestId":"…","decision":"approve"}'
curl -sS -H "$H" -X POST $BASE/sessions/<id>/abort                  # stop
```

## Checking the stack and its configuration

```bash
# reachable?
curl -fsS http://127.0.0.1:18080/health

# sessions / one job
cmp list:  bun run laun -- agent ls            # add --json for scripts
card:      bun run laun -- agent status <id>
history:   bun run laun -- agent log <id>       # --follow to watch live

# your keys (service token required)
GATEWAY_TOKEN=$(python3 -c "import re;print(re.search(r'^GATEWAY_TOKEN=(.*)$',open('.env').read(),re.M).group(1))") \
  bun run laun -- keys ls
```

On the box (when running remotely):

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@<vps> 'sudo docker ps --format "{{.Names}} {{.Status}}"'
ssh -i ~/.ssh/id_ed25519 ubuntu@<vps> 'sudo docker logs --tail 50 deploy-executor-1'

# what the executor is ACTUALLY configured with — worth checking whenever
# behaviour looks like the default, not your intent:
ssh -i ~/.ssh/id_ed25519 ubuntu@<vps> \
  'sudo docker exec deploy-executor-1 printenv | grep -E "EXECUTOR_MODE|RUN_TIMEOUT|RUN_RECOVERY"'
```

### The config gotcha that has already bitten once

**Your local `.env` is the source of truth: `laun setup ssh` writes it
verbatim to the host.** So a key missing locally does not merely default
remotely — it actively *reverts* a value you tuned on the box. It happened:
`EXECUTOR_MODE=rpc` was set on the VPS with `sed`, then the next `setup ssh`
overwrote the remote file and the executor fell back to `json`.

`ensureEnv` now seeds every key the example defines, so the fix is to set the
value in your **local** `.env` and re-run `setup ssh`:

| Key | Default | Why it matters |
|---|---|---|
| `EXECUTOR_MODE` | `json` | `rpc` = one long-lived pi child per session: `steer`, `abort`, pi's own retry |
| `RUN_TIMEOUT_MS` | `600000` (cap `1800000`) | a long research/build job needs 30 min, not 10 |
| `RUN_RECOVERY_ATTEMPTS` | `2` | retries after the first attempt; `0` disables |
| `RPC_IDLE_TTL_MS` | `300000` | when an unused rpc child is reaped |

After changing it: `bun run laun -- setup ssh -i <key> user@<vps>` (idempotent —
same token, same agent key), then re-check `printenv` as above.

## Timeouts, retries, and recovering a killed job

- A run is bounded by `RUN_TIMEOUT_MS`; the whole attempt sequence shares **one**
  deadline, so a retry cannot resurrect a run that died *to the timeout* — that
  is intentional (no unbounded loops). Recovery is for **transport** failures
  ("socket connection was closed"), which it reports as `· retrying (n/m)`.
- Either way the **context survives**: the pi session file keeps every prompt
  and tool result. So the move after any `error` is `continue`, not a fresh
  session:

  ```bash
  bun run laun -- agent say <id> "Continue where you left off. <what remains>; \
  do not redo work that is already done, and write the file incrementally so \
  partial progress survives another interruption."
  ```

  Proven: a 11-tool research job died at the 10-minute cap, was resumed with
  `say`, and finished from its existing context without re-fetching anything.
- Split long work deliberately: have it create the output file **first**, then
  append section by section, so a later kill still leaves usable output.

## Rules

- **Never print, echo, or repeat the agent key** (or `GATEWAY_TOKEN`). It is a
  password: hashed on the gateway, plaintext only in your saved auth file.
- **One session, one run at a time.** Sending a message to a busy session gives
  409; use `agent watch <id>` to block until it settles (exit code tells you the
  outcome), or `say` after it settles. Queued follow-ups while busy are still
  unwired — that is open work, not a bug you should route around.
- Do not assume a public IP works — 8080 is firewalled; tunnel always.
- Give the agent *bounded, verifiable* tasks ("make `bun test` pass", "reply
  with X"), not vague goals; report its transcript back to the user rather than
  paraphrasing success you did not see.

## Where the detail lives

| Question | Doc |
|---|---|
| local dev, tests, running services, troubleshooting | `DEVELOPMENT.md` |
| VPS provisioning, tunnel access, first-bring-up traps | `deploy/remote-setup.md` |
| agent keys vs the service token, rotation, revocation | `examples/agent-keys.md` |
| **what is missing / what to build next** | `docs/roadmap.md` |
| milestones, what is missing, definitions of done | `docs/roadmap.md` |
| lane/worker/validator workflow, gates, gotchas | `DEVELOPMENT.md` (lanes + troubleshooting) |
| model + pi auth setup | `examples/models.md` |
| OpenShell sandboxing (still `OPENSHELL_ENABLED=false`) | `examples/openshell-policy-notes.md` |

## Pre-existing skill note

An older `laun-launch` skill targets a **different** system (a
Portainer-managed home lab, `scripts/launch-agent.sh`, `PORTAINER_URL`) that
does not exist in this repository. Prefer this skill for this repo; ask the
user before touching the other.
