---
name: radicle-oci
description: Operate the VPS reached through the local 'radicle-oci' SSH alias, which now hosts the Sidefeed feed service (it replaced a Radicle seed node on 2026-10-04). Use for Sidefeed deployment, rebuilds, upgrades, service checks, logs, Caddy fronting, or troubleshooting on that host.
---

# VPS remote deployment (Sidefeed)

**Radicle is gone from this host.** It formerly ran `radicle-node` +
`radicle-httpd` as user `seed` behind Caddy. On 2026-10-04 it was stopped,
disabled, backed up, and fully removed (packages, units, data, `seed` account,
apt source list), and the host now runs **Sidefeed** instead. The SSH alias
keeps its original name; ignore the `radicle` in it.

Where the old state went: `/var/backups/radicle/` (a `radicle-home-*.tar.gz`
of `~seed/.radicle` including the node keys and seeded repo, plus copies of the
old systemd units and the Caddyfile). Nothing else Radicle-related remains.

## Start with local configuration

The local machine's SSH configuration is the source of truth for the endpoint.

Ask for the SSH alias if the user has not supplied one. Use `radicle-oci` when
that alias is already configured locally. Do not ask for or print the hostname,
IP address, private key, or passphrase when the alias resolves successfully.

```sh
ssh -G "$SSH_ALIAS" >/dev/null   # validate the alias without exposing settings
ssh "$SSH_ALIAS" 'systemctl is-active sidefeed && systemctl is-enabled sidefeed'
```

The remote account has passwordless `sudo`.

## What runs there

- **`sidefeed.service`** — systemd unit at `/etc/systemd/system/sidefeed.service`,
  `User=sidefeed` (system account, `nologin` shell), hardened
  (`ProtectSystem=strict`, `NoNewPrivileges`, `PrivateTmp`, empty
  `CapabilityBoundingSet`, `ReadWritePaths=/var/lib/sidefeed`).
- **Caddy** — `/etc/caddy/Caddyfile` is a single site,
  `rad.swarnimarun.com { reverse_proxy 127.0.0.1:8080 }`, Let's Encrypt cert.
  Sidefeed therefore listens on **127.0.0.1:8080**, not on a public interface.
- **Layout**: binary `/usr/local/bin/sidefeed` · config
  `/etc/sidefeed/sidefeed.conf` (root-only, contains `SIDEFEED_ADMIN_TOKEN` and
  `SIDEFEED_WEB_DIR`) · data `/var/lib/sidefeed/sidefeed.db` (owner `sidefeed`) ·
  web assets `/var/lib/sidefeed/web` (root:sidefeed, world-readable) · build
  checkout `/home/ubuntu/sidefeed-src` (plain clone of the public repo, branch
  `main`) · build log `/home/ubuntu/build.log` · 4 GB swap at `/swapfile`.
- **The UI is served from `/var/lib/sidefeed/web`** because the config sets
  `SIDEFEED_WEB_DIR`. Files there override the copies compiled into the binary
  and are read **per request**, so an edit applies immediately with no rebuild
  and no restart. Deleting a file falls back to the compiled-in copy.
  The override lookup is **flat** (`dir.join(name)`), so the fonts
  (`Libron-Regular.woff2`, `Libron-Bold.woff2`, `Libron-Italic.woff2`) sit in
  that directory root, not in a `fonts/` subdirectory. Overridable names:
  `index.html`, `app.js`, `styles.css`, `docs.html`, `openapi.json`, and those
  three font files.
- **Host sizing**: 2 vCPU, 954 MiB RAM. The swap file is not optional for
  builds. A cold release build takes ~26 minutes; with the dependency cache warm
  (only sources changed) it is ~3 minutes.

## Service checks

```sh
ssh "$SSH_ALIAS" 'systemctl status sidefeed --no-pager'
ssh "$SSH_ALIAS" 'sudo journalctl -u sidefeed -n 80 --no-pager'
ssh "$SSH_ALIAS" 'curl -sS localhost:8080/healthz; curl -sS localhost:8080/readyz'
```

Public path (DNS + ingress + Caddy + TLS + app):

```sh
curl -sS https://rad.swarnimarun.com/healthz
curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' https://rad.swarnimarun.com/feeds/<slug>.rss
# built-in font, and the unauthenticated feed index the reader uses
curl -sS -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' https://rad.swarnimarun.com/fonts/Libron-Regular.woff2
curl -sS https://rad.swarnimarun.com/api/v1/public/feeds
```

## Rebuild and upgrade

```sh
ssh "$SSH_ALIAS" 'cd /home/ubuntu/sidefeed-src && git fetch --depth 1 origin main && git reset --hard origin/main'
ssh "$SSH_ALIAS" 'cd /home/ubuntu/sidefeed-src && nohup env CARGO_BUILD_JOBS=2 $HOME/.cargo/bin/cargo build --release > /home/ubuntu/build.log 2>&1 &'
# poll /home/ubuntu/build.log until "Finished" (background it so SSH hiccups cannot kill it)
ssh "$SSH_ALIAS" 'sudo install -m 0755 -o root -g root /home/ubuntu/sidefeed-src/target/release/sidefeed /usr/local/bin/sidefeed && sudo systemctl restart sidefeed'
# stage the UI flat, then verify (assets also work straight from the binary)
ssh "$SSH_ALIAS" 'cd /home/ubuntu/sidefeed-src && sudo cp -f src/web/index.html src/web/app.js src/web/styles.css src/web/docs.html src/web/openapi.json /var/lib/sidefeed/web/ && sudo cp -f src/web/fonts/*.woff2 src/web/fonts/Libron-LICENSE.txt /var/lib/sidefeed/web/ && sudo chown -R root:sidefeed /var/lib/sidefeed/web'
ssh "$SSH_ALIAS" 'curl -sS localhost:8080/readyz; curl -sS localhost:8080/ | grep -c icon-btn'
```

Serving newer assets needs no rebuild at all: copy them into
`/var/lib/sidefeed/web` and reload the page. Only Rust changes need the build.

Config changes go in `/etc/sidefeed/sidefeed.conf`, then
`sudo systemctl restart sidefeed`. Keep the file `root:root 0600`.

## Traps specific to this host

- **The binary takes no CLI flags.** Never run `sidefeed` with `--help` or in
  the foreground: it ignores arguments, binds `0.0.0.0:8080` with no admin
  token, creates a stray `sidefeed.db` in the working directory, and blocks
  forever. Always drive it through `systemctl`.
- **`authorize()` fails open**: when `SIDEFEED_ADMIN_TOKEN` is unset the
  management API is unauthenticated. Always keep a token set, and keep the
  listener bound to `127.0.0.1`.
- **Port pairing**: the app's `SIDEFEED_LISTEN` and Caddy's `reverse_proxy`
  must agree (`127.0.0.1:8080`). Change both or neither.
- **Data lives in `/var/lib/sidefeed`**; `ProtectSystem=strict` means any other
  path is read-only to the service. Add new writable paths to `ReadWritePaths`.
- Oracle cloud ingress allows 80/443 (and 22); it does **not** expose 8080, so
  the app port is not internet-reachable. Do not assume that is a security
  boundary — the reverse proxy is not an auth boundary either.
- The repo is public, so the on-box clone needs no credentials.
- **Checking whether the build is running**: `pgrep -f "cargo build --release"`
  matches the SSH command string itself, so it reports a false "yes". Trust the
  log instead: `tail -1 /home/ubuntu/build.log` says `Finished` when done.
- **Font checks in a browser**: `document.fonts.check('13px Libron')` returns
  false until the faces finish loading, so await `document.fonts.ready` first or
  you will misread a healthy deployment as broken.

## Safety rules

- Never print, transmit, or commit the value of `SIDEFEED_ADMIN_TOKEN` or the
  contents of `/etc/sidefeed/sidefeed.conf`. To use it in a command, read it
  into a shell variable and never echo it.
- Before changing remote config, make a timestamped backup and preserve its
  owner and mode.
- Restart only the service the change requires; verify `/readyz` afterward.
- Do not alter DNS, cloud ingress, repository visibility, or firewall rules
  unless the user explicitly requests that exact change.
- The public dashboard, `/docs`, and `/openapi.json` are intentionally
  unauthenticated; only management routes use the bearer token.

## References

- Service source: https://github.com/swarnimarun/sidefeed
- Radicle history: https://radicle.xyz/guides/user/
