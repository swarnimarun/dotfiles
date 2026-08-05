---
name: sidefeed
description: Manage feeds on a Sidefeed instance through its HTTP API — add sources, build named feeds, filter and search items, poll on demand, import OPML, publish RSS/JSON/newsletter/thread outputs, and reason about what the reader shows. Use when the user asks to add or curate feeds, inspect a feed's items, produce a digest or feed URL, import an OPML list, or automate a Sidefeed instance.
---

# Sidefeed (feed manager)

Sidefeed turns RSS, Atom, JSON Feed and ActivityPub sources into named feeds backed by one SQLite file. It renders the same feed as REST JSON, RSS, JSON Feed, an SSE stream, a newsletter digest, or a 280-char thread.

The operator's instance is `https://rad.swarnimarun.com`. Host work (systemd, Caddy, rebuilds, logs) belongs to the `radicle-oci` skill, not this one.

Two facts shape every task here:

- **Reads of public feeds need no credentials.** Anything that changes state needs `Authorization: Bearer <token>`.
- **There is no delete or edit endpoint.** What the API creates stays until it is removed in SQL on the host. Choose slugs and titles deliberately.

## Token

Generated on the host, stored root-only, never printed by assistants or committed:

```sh
ssh radicle-oci 'sudo awk -F= "/^SIDEFEED_ADMIN_TOKEN=/{print \$2}" /etc/sidefeed/sidefeed.conf'
```

Read it into a shell variable when a write is needed. Never put it in a URL, a commit, a log line, or a chat message.

## Add a feed (the normal path)

```sh
BASE=https://rad.swarnimarun.com
TOKEN=$(ssh radicle-oci 'sudo awk -F= "/^SIDEFEED_ADMIN_TOKEN=/{print \$2}" /etc/sidefeed/sidefeed.conf')
AUTH="authorization: Bearer $TOKEN"

# 1. Add the origin as a source. kind: auto | rss | atom | json | activitypub.
SRC=$(curl -sS -X POST $BASE/api/v1/sources -H "$AUTH" -H 'content-type: application/json' \
  -d '{"url":"https://blog.rust-lang.org/feed.xml","title":"Rust Blog"}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["id"])')

# 2. Create the feed. slug is lowercase letters, digits and hyphens, max 64 chars.
curl -sS -X POST $BASE/api/v1/feeds -H "$AUTH" -H 'content-type: application/json' \
  -d '{"slug":"rust","title":"Rust Blog","description":"Language news","public":true}'

# 3. Connect them, then fetch now: the worker only polls every 15 minutes.
curl -sS -o /dev/null -w '%{http_code}\n' -X POST $BASE/api/v1/feeds/rust/sources/$SRC -H "$AUTH"
curl -sS -X POST $BASE/api/v1/sources/$SRC/poll -H "$AUTH"      # {"imported":10}
```

`public: true` is what makes a feed readable without a token, listed in the reader, and reachable in every output format. A private feed returns 401 on those same URLs.

## Curate

- `include_terms` and `exclude_terms` take comma-separated terms, matched case-insensitively against title, summary, content and tags. Include keeps items matching any term; exclude drops matches. This is how one noisy source feeds a narrow feed.
- One source can feed many feeds: attach it as often as needed.
- OPML: `POST /api/v1/import/opml` with the document as the request body returns `{"created":[...],"skipped":N}`; `skipped` counts URLs already known.
- Polling follows `SIDEFEED_FETCH_INTERVAL_SECONDS` (default 900). Manual polls use conditional GET (ETag / Last-Modified), so a repeated poll usually imports nothing even when the feed is healthy.

## Read and publish

```sh
curl -sS "$BASE/api/v1/feeds/rust/items?limit=20"     # newest first; page with ?cursor=
curl -sS "$BASE/api/v1/feeds/rust/search?q=cargo"     # SQLite FTS5
curl -sS "$BASE/api/v1/feeds/rust/stream"             # SSE, event: item
curl -sS "$BASE/api/v1/public/feeds"                  # token-free index of public feeds

curl -sS "$BASE/feeds/rust.rss"                       # RSS 2.0
curl -sS "$BASE/feeds/rust.json"                      # JSON Feed 1.1
curl -sS "$BASE/feeds/rust/newsletter"                # HTML digest; ?format=text&limit=100
curl -sS "$BASE/feeds/rust/thread.json"               # social thread payload
```

Only public feeds are token-free. `/api/v1/public/feeds` returns `slug`, `title`, `description` and nothing else, so it never leaks private feed names or filters.

## What surprises people

- **Bodies are passthrough, not generated.** If the origin ships no summary, the reader says so. Link-only bodies such as Hacker News' "Comments" are treated as empty, and aggregator items (Hacker News, Reddit, Lobsters, Tildes) surface the discussion as a separate `comments` link beside `original`. That covers both shapes: HN puts the article in the item URL and the thread in the body, Reddit does the reverse.
- **`/api/v1/feeds/{slug}/semantic` returns 500 by default.** It needs an embedding provider, and the shipped default is `SIDEFEED_EMBEDDING_PROVIDER=disabled`. Use `/search` unless `SIDEFEED_EMBEDDING_URL`, `_TOKEN` and `_PROVIDER` are configured.
- **Source URLs are SSRF-checked.** Loopback, RFC1918 and link-local addresses are rejected when the source is created, so a feed cannot be pointed back at the host or its private network.
- **Retention deletes.** `SIDEFEED_RETENTION_DAYS` (default 90) prunes older items. An empty-looking feed may just have nothing recent.
- **The web reader is read-only.** It never asks for a token and cannot create or change anything; writes are API-only and the reader lists public feeds only.
- **Peers trade public items.** `/api/v1/peers` plus `/federation/v1/items` exchange batches between instances with an HMAC `shared_secret`. Treat that secret exactly like the admin token.
- **Visibility works at two levels.** A feed's `public` flag gates the HTTP read paths: when it is false, items, RSS, JSON and the digest all require the token. Each item also carries its own `visibility` field, and the peer federation export shares only `public` items. Items ingested from sources default to `public`.

## Useful facts from the host

- The UI is served from `/var/lib/sidefeed/web` (`SIDEFEED_WEB_DIR`) and read per request, so asset edits need no rebuild or restart; Rust changes need `cargo build --release` on the box. Details in the `radicle-oci` skill.
- Relevant configuration names: `SIDEFEED_PUBLIC_URL` (baked into RSS/JSON links), `SIDEFEED_FETCH_INTERVAL_SECONDS`, `SIDEFEED_FETCH_TIMEOUT_SECONDS`, `SIDEFEED_MAX_RESPONSE_BYTES`, `SIDEFEED_PEER_MAX_ITEMS`, `SIDEFEED_RETENTION_DAYS`, `SIDEFEED_LISTEN`, `SIDEFEED_DATABASE_URL`.

## References

- Instance: https://rad.swarnimarun.com · reference docs `/docs` · machine spec `/openapi.json`
- Source: https://github.com/swarnimarun/sidefeed
