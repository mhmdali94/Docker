# GPT Project Summary

This summary is based on a read-through of all 105 non-`.git` files in this repository on 2026-04-18.

## Overview

This repository is a collection of Ubuntu-focused, one-command Docker installer scripts for self-hosted services. Each service lives in its own category folder and is paired with two files:

- `README.md` for usage, ports, credentials, and access notes
- `service-name-ubuntu.sh` for automated installation and startup

The project is aimed at fast demo or test deployments rather than hardened production systems. That intent is stated repeatedly in the root docs and in many service READMEs.

## Repository Facts

- Total non-`.git` files: 105
- Markdown files: 53
- Shell installer scripts: 51
- License files: 1
- Categories: 15
- Services: 51
- Target platform: Ubuntu `22.04` and `24.04`
- Primary install location: `/root/docker/<service>`

## Directory Model

The repo follows a consistent folder layout:

```text
category/service-name/
|- README.md
`- service-name-ubuntu.sh
```

Top-level documentation files:

- `README.md`
- `CONTRIBUTING.md`
- `LICENSE`

## Categories And Services

| Category | Services |
| --- | --- |
| analytics | plausible, umami |
| backup | duplicati |
| communication | mattermost, ntfy |
| databases | influxdb, mariadb, minio, mongodb, postgres, redis |
| dev | gitea, harbor, woodpecker |
| email | listmonk, mailcow, mailu |
| files | filebrowser, nextcloud, paperless-ngx |
| management | portainer |
| media | audiobookshelf, immich, jellyfin, kavita, navidrome |
| monitoring | beszel, grafana, graylog, netdata, prometheus, uptime-kuma |
| networking | adguardhome, npm, pihole |
| remote-access | guacamole, remotely, rustdesk |
| security | authentik, authelia, vaultwarden |
| tools | it-tools, stirling-pdf |
| vpn | 3x-ui, headscale, netbird, openvpn-as, outline, pritunl, softether, wireguard-easy |

## Common Installer Pattern

Most installer scripts follow the same operational flow:

1. Display banner and demo/testing warning.
2. Require root privileges.
3. Verify Ubuntu version.
4. Check for Docker and install it if missing.
5. Check for Docker Compose V2.
6. Remove existing containers and often prune unused Docker networks.
7. Recreate the service directory under `/root/docker/<service>`.
8. Generate credentials, secrets, environment files, or `docker-compose.yml`.
9. Start the stack with `docker compose up -d`.
10. Verify container startup.
11. Run a health check loop with HTTP, HTTPS, or TCP probes.
12. Print access details and generated credentials.

Shared script traits seen across the repo:

- `set -e` is standard.
- Helper functions such as `info`, `warn`, `error`, and `section` appear in almost every script.
- Credentials are commonly generated from `/dev/urandom`.
- Re-runs usually perform a destructive cleanup of the previous service directory for a fresh reinstall.
- Multi-container stacks usually define an isolated bridge network per service.

## README Pattern

Most READMEs follow one of two styles.

Newer pattern:

- title and short service description
- demo/testing disclaimer
- author credit
- usage block with `wget`, `chmod +x`, and `sudo bash`
- credentials table
- ports table
- connect/access examples

Older pattern:

- quick install section
- explanation of what the service does
- features list
- directory structure notes
- official docs links

Across both styles, the documents assume an Ubuntu host and a root-run installer that prepares everything under `/root/docker/<service>`.

## Operational Characteristics

The repository favors convenience and repeatability over hardening.

Common patterns:

- services expose web UIs on `3000`, `3001`, `3002`, `5000`, `808x`, `809x`, `900x`, and similar ports
- databases expose their default ports directly for local or LAN use
- health checks usually retry for 60 seconds; slower stacks often wait 120 seconds
- some services rely on host networking or extra Linux capabilities for protocol-heavy workloads

Security-sensitive or high-access patterns appear in several scripts:

- Docker socket mounts for services such as Woodpecker, Portainer, and some Authentik components
- broad host mounts for tools such as FileBrowser, Duplicati, and Netdata
- default or static credentials in some service docs or configs
- settings that are intentionally relaxed for demos, such as signups enabled or reduced internal security flags

## Important Repo-Wide Notes

- The project repeatedly states that it is for demo and testing use only.
- Production concerns such as hardening, least privilege, secret rotation, TLS lifecycle, backups, and long-term upgrades are not the main focus.
- Re-running a script often wipes prior config and data for that service.
- Many services require post-install manual steps such as DNS setup, admin onboarding, SMTP config, OAuth setup, or external client pairing.

## Documentation And Maintenance Findings

The repo is useful and fairly consistent in structure, but the documentation is not fully in sync with the actual file tree.

Main mismatches found:

- The root `README.md` says the repo has 29 services, but the current tree contains 51 services.
- The root `README.md` omits entire active categories such as `analytics`, `backup`, `communication`, and `dev`.
- Several category counts in the root `README.md` are outdated.
- Some service READMEs do not match the live script behavior for ports or credentials.
- Some download URLs still use placeholder or incorrect GitHub paths that do not match the real folder structure.
- `CONTRIBUTING.md` prescribes a strict step order, especially for firewall rules before health checks, but that rule is not consistently reflected in every script.

Examples of doc-to-script mismatches:

- `files/filebrowser/README.md` documents `8080` and `admin/admin`, while the script uses `8082` and a different password.
- `networking/pihole/README.md` describes access like a port-80 install, while the script exposes `8084`.
- `remote-access/guacamole/README.md` documents `8090`, while the script uses `8085`.

## Project Strengths

- Clear per-service organization.
- Consistent install story across many services.
- Good coverage of self-hosting categories.
- Fast repeatable demo setup for Ubuntu hosts.
- `CONTRIBUTING.md` provides a strong baseline pattern for future additions.

## Project Risks

- Root documentation is stale relative to the actual repo contents.
- Some per-service READMEs contain broken or outdated install paths.
- Script behavior is not fully normalized across all services despite the documented standard.
- Several installers intentionally make security tradeoffs that are acceptable for demos but risky for production use.

## Bottom Line

This is a broad self-hosting installer collection built around 51 service-specific Docker scripts and matching READMEs, organized cleanly by category and optimized for quick Ubuntu demo deployments. The repo is strongest as a rapid setup library and weakest in documentation freshness and production hardening, so the scripts are best treated as disposable labs, reference implementations, or starting points for more secure downstream setups.
