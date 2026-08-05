---
name: radicle-oci
description: Operate and troubleshoot a Radicle deployment backed by an OCI or other remote seed through a locally configured SSH alias. Use when the user asks about Radicle node connectivity, private repository seeding, peer isolation, node limits, Git/JJ workflows, service checks, or safe configuration changes.
---

# Radicle remote deployment

Keep deployment-specific hosts, usernames, node IDs, repository IDs, paths, and network details out of this skill. The local machine's SSH configuration is the source of truth for the remote endpoint.

## Start with local configuration

Ask for the SSH alias if the user has not supplied one. Use `radicle-oci` when that alias is already configured locally. Do not ask for or print the hostname, IP address, private key, or passphrase when the alias resolves successfully.

Check the alias without exposing its private settings:

```sh
ssh -G "$SSH_ALIAS" >/dev/null
```

Use the alias for every remote command:

```sh
ssh "$SSH_ALIAS" 'command -v rad && rad node config && rad node status'
ssh "$SSH_ALIAS" 'sudo systemctl status radicle-node.service --no-pager'
```

If discovery fails, ask only for the missing remote Radicle user, `RAD_HOME`, service names, or repository identifier. Store those values in the user's local environment or SSH configuration, never in this skill or a public repository.

## Safe diagnostics

Local node:

```sh
rad node config
rad node status
pgrep -alf radicle-node
```

Remote node:

```sh
ssh "$SSH_ALIAS" 'rad node config'
ssh "$SSH_ALIAS" 'rad node status'
ssh "$SSH_ALIAS" 'sudo journalctl -u radicle-node.service -n 80 --no-pager'
```

When the remote Radicle installation belongs to a separate OS account, use the configured remote account and `RAD_HOME` after confirming them with the user:

```sh
ssh "$SSH_ALIAS" "sudo -u \"$RADICLE_USER\" env RAD_HOME=\"$RAD_HOME\" rad node config"
```

If the local node reports a missing `control.sock`, start it with `rad node start` and let the user enter the passphrase. If duplicate processes exist, run `rad node stop`, inspect `pgrep`, and terminate only the identified stale duplicate before starting one node.

## Private repositories

Ask for the repository RID and the authorized seed DID when the operation needs them. Do not infer either value from a hostname or copy them into this skill.

For a new private repository:

```sh
rad init --private
rad id update --title "Allow remote seed" --allow "did:key:$SEED_DID"
```

Run remote seed operations through the alias and the user's configured Radicle account:

```sh
ssh "$SSH_ALIAS" "sudo -u \"$RADICLE_USER\" env RAD_HOME=\"$RAD_HOME\" rad seed \"$RID\""
rad sync "$RID" --announce --seed "$SEED_DID" --replicas 1 --timeout 60s
rad inspect "$RID" --policy
```

Private repositories are not encrypted at rest. Anyone with root access to the remote VM or Radicle account can read stored data. Changing a previously public repository to private cannot recall historical copies.

## Git and JJ

Use the repository's existing Radicle remote:

```sh
git push rad HEAD
git push rad HEAD:refs/patches
```

For JJ, use a colocated Git repository and push through the same remote:

```sh
jj git init --colocate
jj describe -m "Describe change"
git push rad HEAD:refs/patches
```

## Access-control boundaries

Connection limits and restrictive seeding policies do not authenticate arbitrary inbound peers. Treat publicly reachable P2P ports as exposed. Use the user's approved network controls, such as a private network or a narrowly scoped firewall allow-list, only when explicitly requested and after checking lockout risk.

An HTTP reverse proxy is not an authentication boundary. Do not expose administration functionality through it without an access layer.

## Safety rules

- Never print, transmit, or commit Radicle private keys, passphrases, or `RAD_PASSPHRASE` values.
- Never store deployment-specific hosts, usernames, node IDs, RIDs, public IPs, or topology in this skill.
- Do not use a seed key as a second active node identity.
- Before changing a remote Radicle config, make a timestamped backup and preserve its owner and mode.
- Restart only the service required for the requested config change; verify the local peer afterward.
- Do not alter DNS, cloud ingress, repository visibility, or firewall rules unless the user explicitly requests that exact change.

## References

- https://radicle.xyz/guides/protocol/#private-repositories
- https://radicle.xyz/guides/user/#selectively-revealing-repositories
- https://radicle.xyz/guides/seeder/#a-selective-seeding-policy
