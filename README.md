# Docker Self-Hosted Services Collection

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Services](https://img.shields.io/badge/Services-130+-brightgreen)
![Categories](https://img.shields.io/badge/Categories-28-purple)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%20%7C%2024.04-orange)
![Made by](https://img.shields.io/badge/Made%20by-Mohammed%20Ali%20Elshikh-blue)

> ⚠️ **Scripts in this repository are provided for demo and testing purposes only and are not intended for production use.**

A growing collection of one-command Docker installer scripts for self-hosted services, organized by category. Each script handles Docker installation, credential generation, stack startup, and a basic health check — no manual configuration required.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## At a Glance

- **130+ services** across **28 categories**
- One-command install — just `wget` and `bash`
- Ubuntu 22.04 and 24.04 support
- Auto-installs Docker & Docker Compose V2 if missing
- Generates secure credentials on every run
- Clean reinstall — re-running removes the previous deployment
- Each service deploys under `/root/docker/<service>`

---

## Quick Start

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/<category>/<service>/<service>-ubuntu.sh
chmod +x <service>-ubuntu.sh
sudo bash <service>-ubuntu.sh
```

**Example — install Jellyfin:**
```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/jellyfin/jellyfin-ubuntu.sh
chmod +x jellyfin-ubuntu.sh
sudo bash jellyfin-ubuntu.sh
```

**Example — install Vaultwarden:**
```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/vaultwarden/vaultwarden-ubuntu.sh
chmod +x vaultwarden-ubuntu.sh
sudo bash vaultwarden-ubuntu.sh
```

See the `README.md` inside each service folder for exact ports, credentials, and post-install steps.

---

## Requirements

- Ubuntu `22.04` or `24.04`
- Root or sudo access
- Internet access (for package installs and Docker image pulls)
- Firewall ports open as required by the selected service

---

## Categories

| Category | Services |
|---|---|
| [AI](./ai/) | Ollama, Open WebUI, AnythingLLM, Flowise, LocalAI, Dify, Langfuse, LibreChat, ComfyUI, Whisper, Qdrant, SearXNG |
| [Analytics](./analytics/) | Plausible, Umami, Metabase, NocoDB, Baserow, Redash, Matomo |
| [Accounting](./accounting/) | Akaunting, Invoice Ninja |
| [Automation](./automation/) | N8N, Node-RED, ActivePieces |
| [Backup](./backup/) | Duplicati, Kopia, Restic REST Server |
| [Clinic](./clinic/) | OpenMRS, GNU Health, OpenEMR |
| [CMS](./cms/) | Directus, Strapi, Payload, PocketBase, WordPress |
| [Communication](./communication/) | Mattermost, ntfy, Chatwoot, Zulip, Matrix + Element, RocketChat, Jitsi |
| [CRM](./crm/) | SuiteCRM, EspoCRM |
| [Databases](./databases/) | PostgreSQL, MariaDB, MongoDB, Redis, MinIO, InfluxDB, Elasticsearch, ClickHouse, Neo4j, MeiliSearch, Adminer, pgAdmin |
| [Dev](./dev/) | Gitea, GitLab, Harbor, Woodpecker, SonarQube, Infisical, Plane, Nexus, GlitchTip, Code-Server, Verdaccio, Coder, Jenkins, Coolify, Weblate |
| [Ecommerce](./ecommerce/) | Medusa, PrestaShop, Saleor, Shopware |
| [Education](./education/) | Moodle, Open edX |
| [Email](./email/) | Listmonk, Mailcow, Mailu, Mautic |
| [ERP](./erp/) | Odoo 16, Odoo 17, Odoo 18, ERPNext, Dolibarr, iDempiere |
| [Files](./files/) | FileBrowser, Nextcloud, Paperless-ngx |
| [Finance](./finance/) | Maybe Finance |
| [Gaming](./gaming/) | GameVault, Pterodactyl |
| [HR](./hr/) | OrangeHRM, IceHRM |
| [Low-Code](./low-code/) | Appsmith, Tooljet |
| [Management](./management/) | Portainer, Dockge, Watchtower, Dashy, Homarr |
| [Media](./media/) | Immich, Jellyfin, PhotoPrism, Navidrome, Audiobookshelf, Kavita, Komga, FreshRSS, TubeArchivist, Overseerr, PeerTube, Plex, Sonarr, Radarr, Lidarr, Bazarr, Prowlarr |
| [Monitoring](./monitoring/) | Grafana, Prometheus, Uptime Kuma, Netdata, Beszel, Graylog, Loki, SigNoz, OpenObserve, VictoriaMetrics, Healthchecks, Cachet, Gatus |
| [Networking](./networking/) | Nginx Proxy Manager, Traefik, Caddy, AdGuard Home, Pi-hole, Technitium DNS, Cloudflared, FRP, HAProxy, Nginx |
| [Project Management](./project-management/) | Leantime, OpenProject |
| [Remote Access](./remote-access/) | Guacamole, RustDesk, Remotely, Kasm |
| [Security](./security/) | Authelia, Authentik, Vaultwarden, Keycloak, CrowdSec, Wazuh, Passbolt, DefectDojo, OpenVAS, Trivy, Vault, OWASP ZAP |
| [Social](./social/) | Mastodon, Lemmy, Pixelfed, Misskey, WriteFreely |
| [Support](./support/) | Zammad, osTicket, Faveo, FreeScout, Peppermint |
| [Tools](./tools/) | IT-Tools, Stirling-PDF, Excalidraw, Outline, Memos, BookStack, Docmost, Vikunja, Firefly III, Monica, Twenty, Typebot, Ghost, HedgeDoc, Formbricks, Mealie, Tandoor, Kimai, Shlink, Wallabag, Hoarder, LibreTranslate, Docuseal, Actual Budget, Changedetection, Joplin Server, Linkwarden |
| [VPN](./vpn/) | WireGuard Easy, NetBird, Headscale, 3X-UI, OpenVPN AS, Pritunl, SoftEther, Outline |

---

## How Scripts Work

Every script follows the same flow:

1. Check for root privileges
2. Verify Ubuntu 22.04 / 24.04
3. Install or verify Docker
4. Install or verify Docker Compose V2
5. Remove any previous deployment of the same service
6. Create `/root/docker/<service>` and subdirectories
7. Generate credentials and write configuration files
8. Pull images and start the Docker Compose stack
9. Verify containers are running
10. Run a basic HTTP health check
11. Open required firewall ports via UFW (if installed)
12. Print access URL, credentials, and management tips

---

## Repository Structure

```
.
├── ai/
├── analytics/
├── accounting/
├── automation/
├── backup/
├── clinic/
├── cms/
├── communication/
├── crm/
├── databases/
├── dev/
├── ecommerce/
├── education/
├── email/
├── erp/
├── files/
├── finance/
├── gaming/
├── hr/
├── low-code/
├── management/
├── media/
├── monitoring/
├── networking/
├── project-management/
├── remote-access/
├── security/
├── social/
├── support/
├── tools/
├── vpn/
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

Per-service layout:

```
category/service-name/
├── README.md
└── service-name-ubuntu.sh
```

---

## Management Commands

After installation, use these commands to manage any service:

```bash
# View live logs
docker logs -f <container-name>

# Stop the service
cd /root/docker/<service> && docker compose down

# Start the service
cd /root/docker/<service> && docker compose up -d

# Restart the service
cd /root/docker/<service> && docker compose restart

# Update to the latest image
cd /root/docker/<service> && docker compose pull && docker compose up -d

# Remove service completely (including data)
cd /root/docker/<service> && docker compose down -v
rm -rf /root/docker/<service>
```

---

## Important Notes

- These setups are intended for **demo, testing, and lab use only**.
- Credentials are generated or set to defaults during installation — change them before exposing services publicly.
- Some services require additional post-install steps (DNS, SMTP, OAuth, reverse proxy config, client-side setup).
- Some installers use host networking, Docker socket access, or elevated capabilities where required by the service.
- For production-grade deployments, treat these scripts as starting points and apply proper hardening.

---

## Contributing

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for script structure, naming conventions, cleanup rules, health check patterns, and port allocation guidance.

---

## Support

If these scripts save you time, you can support the project:

**USDT (TRC-20):** `TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i`

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
