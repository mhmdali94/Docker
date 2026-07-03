# Docker Self-Hosted Services Collection

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Services](https://img.shields.io/badge/Services-444+-brightgreen)
![Categories](https://img.shields.io/badge/Categories-36-purple)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%20%7C%2024.04-orange)
![Made by](https://img.shields.io/badge/Made%20by-Mohammed%20Ali%20Elshikh-blue)

> ⚠️ **Scripts in this repository are provided for demo and testing purposes only and are not intended for production use.**

A growing collection of one-command Docker installer scripts for self-hosted services, organized by category. Each script handles Docker installation, credential generation, stack startup, and a basic health check — no manual configuration required.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## At a Glance

- **444+ services** across **36 categories**
- One-command install — just `wget` and `bash`
- Ubuntu 22.04 and 24.04 support
- Auto-installs Docker & Docker Compose V2 if missing
- Generates secure credentials on every run
- Clean reinstall — re-running removes the previous deployment
- Each service deploys under `/root/docker/<service>`
- Every Docker image is verified against its registry before release

---

## What's New — July 2026

- **200+ new services** added across three waves: Supabase, Appwrite, Sentry, Apache Airflow, OpenSearch, LocalStack, Overleaf, Zitadel, Pocket ID, AFFiNE, Wiki.js, Cal.com, Penpot, Zabbix, UniFi & Omada, MeshCentral, Taiga, Forgejo, NetBox, MISP, TheHive, RomM, LobeChat, Postiz, Gluetun, Backrest, Traccar, and many more
- **Three new categories:** [Downloads](./downloads/), [Cameras](./cameras/) and [3D Printing](./3d-printing/)
- All existing scripts audited: dead Docker images replaced, broken configs fixed (Hoarder migrated to its Karakeep successor image)
- Services without a public image **build or install from official sources** (Medusa, Payload, Faveo, GNU Health, IceHRM, Supabase, Appwrite, Sentry, Dokploy)

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

**Example — install Wiki.js:**
```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/wikijs/wikijs-ubuntu.sh
chmod +x wikijs-ubuntu.sh
sudo bash wikijs-ubuntu.sh
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
| [3D Printing](./3d-printing/) | Manyfold, Octoprint, Spoolman |
| [Accounting](./accounting/) | Akaunting, Invoice Ninja, InvoiceShelf |
| [AI](./ai/) | AnythingLLM, Chroma, ComfyUI, Dify, Flowise, Kokoro, Langflow, Langfuse, LibreChat, LiteLLM, LobeChat, LocalAI, Milvus, Mindsdb, Ollama, Open WebUI, Perplexica, Qdrant, SearXNG, SillyTavern, Speaches, Weaviate, Whisper |
| [Analytics](./analytics/) | Baserow, Lightdash, Matomo, Metabase, NocoDB, Plausible, Redash, Shynet, Superset, Swetrix, Umami |
| [Automation](./automation/) | ActivePieces, Airflow, Automatisch, Huginn, Kestra, N8N, Node-RED, Semaphore, Windmill |
| [Backup](./backup/) | Backrest, Borgmatic, Duplicati, Kopia, Restic REST Server, UrBackup |
| [Cameras](./cameras/) | Frigate, go2rtc, Scrypted |
| [Clinic & Health](./clinic/) | Fasten Health, GNU Health, Nightscout, OpenEMR, OpenMRS, wger |
| [CMS](./cms/) | Directus, Drupal, Grav, Joomla, Payload, PocketBase, Strapi, WordPress |
| [Communication](./communication/) | Apprise, Chatwoot, ejabberd, Gotify, Jitsi, LiveKit, Matrix + Element, Mattermost, MiroTalk, Mumble, ntfy, RocketChat, Signal Api, Teamspeak, Zulip |
| [CRM](./crm/) | EspoCRM, SuiteCRM |
| [Databases](./databases/) | Adminer, Arangodb, ClickHouse, Cloudbeaver, CouchDB, Dragonfly, Elasticsearch, InfluxDB, MariaDB, MeiliSearch, MinIO, MongoDB, NATS, Neo4j, Opensearch, pgAdmin, PostgreSQL, Questdb, RabbitMQ, Redis, Surrealdb, TimescaleDB, Typesense, Valkey |
| [Dev](./dev/) | Appwrite, Atuin, Code-Server, Coder, Coolify, Dokploy, Flagsmith, Forgejo, Gitea, GitLab, Gitness, GlitchTip, Harbor, Hoppscotch, Infisical, Jenkins, Judge0, Localstack, Nexus, OneDev, Opengist, Plane, Registry, Sentry, SonarQube, Supabase, Tolgee, Unleash, Verdaccio, Wakapi, Weblate, Woodpecker |
| [Downloads](./downloads/) | Aria2 + AriaNg, Deluge, MeTube, Nzbget, Pinchflat, qBittorrent, SABnzbd, Slskd, Transmission |
| [Ecommerce](./ecommerce/) | Bagisto, EverShop, Medusa, PrestaShop, Saleor, Shopware |
| [Education](./education/) | Kolibri, Moodle |
| [Email](./email/) | addy.io, Docker Mailserver, Keila, Listmonk, Mailcow, Mailpit, Mailu, Mautic, Roundcube, Snappymail, Stalwart |
| [ERP](./erp/) | Dolibarr, ERPNext, Grocy, iDempiere, InvenTree, Odoo 16, Odoo 17, Odoo 18, Part Db, Tryton |
| [Files](./files/) | copyparty, FileBrowser, Filestash, Nextcloud, OpenCloud, PairDrop, Paperless-ngx, ProjectSend, Seafile, Seaweedfs, SFTPGo, Syncthing |
| [Finance](./finance/) | Ghostfolio, Maybe Finance, Wallos |
| [Gaming](./gaming/) | 7 Days to Die, ARK, Barotrauma, Core Keeper, Crafty, CS2, Don't Starve Together, Enshrouded, Factorio, Foundryvtt, Garry's Mod, Left 4 Dead 2, Minecraft Bedrock, Minecraft Java, Minetest, OpenRA, OpenTTD, Palworld, Project Zomboid, Pterodactyl, Rust, Satisfactory, Team Fortress 2, Terraria, V Rising, Valheim, Vintage Story |
| [HR](./hr/) | Horilla, IceHRM, OrangeHRM |
| [IoT](./iot/) | EMQX, ESPHome, Evcc, Home Assistant, Mosquitto, openHAB, TeslaMate, ThingsBoard, Traccar, Zigbee2MQTT, Zwave Js Ui |
| [Low-Code](./low-code/) | Appsmith, Budibase, NocoBase, Tooljet |
| [Management](./management/) | Dashy, Diun, Dockge, Glance, Homarr, Homepage, Komodo, Portainer, Watchtower, What's Up Docker, Yacht |
| [Media](./media/) | Audiobookshelf, Bazarr, Calibre-Web, ErsatzTV, FreshRSS, Immich, Jellyfin, Jellyseerr, Jellystat, Kavita, Komga, Lidarr, Maintainerr, Miniflux, Navidrome, Overseerr, PeerTube, PhotoPrism, Plex, Prowlarr, Radarr, RomM, Rss Bridge, Sonarr, Suwayomi, Tautulli, Tdarr, Threadfin, TubeArchivist, Wizarr, Your Spotify |
| [Monitoring](./monitoring/) | Beszel, Cachet, Checkmk, Dozzle, Gatus, Glances, Grafana, Graylog, Healthchecks, Kener, LibreNMS, Loki, Netdata, ntopng, OpenObserve, Prometheus, Scrutiny, SigNoz, SmokePing, Speedtest Tracker, Uptime Kuma, VictoriaMetrics, Zabbix |
| [Networking](./networking/) | AdGuard Home, Blocky, Caddy, Cloudflare Ddns, Cloudflared, FRP, HAProxy, LibreSpeed, NetAlertX, Nginx, Nginx Proxy Manager, Omada Controller, Pi-hole, Tailscale, Technitium DNS, Traefik, Unbound, UniFi Controller, Zoraxy |
| [POS](./pos/) | OpenSourcePOS |
| [Project Management](./project-management/) | Kanboard, Leantime, OpenProject, Redmine, Taiga, WeKan |
| [Remote Access](./remote-access/) | Guacamole, Kasm, MeshCentral, Remotely, RustDesk, Sshwifty |
| [Security](./security/) | Authelia, Authentik, CrowdSec, Cyberchef, DefectDojo, Keycloak, MISP, NetBox, OpenVAS, OWASP ZAP, Passbolt, Password Pusher, Pocket ID, Step Ca, TheHive, Trivy, Vault, Vaultwarden, Wazuh, Yopass, Zitadel |
| [Social](./social/) | Bluesky PDS, Flarum, GoToSocial, Lemmy, Mastodon, Misskey, NodeBB, Pixelfed, Postiz, WriteFreely |
| [Support](./support/) | Faveo, FreeScout, osTicket, Peppermint, Zammad |
| [Tools](./tools/) | Actual Budget, AFFiNE, ArchiveBox, Baby Buddy, Beaverhabits, BookStack, Cal.com, Changedetection, ConvertX, Dawarich, Docmost, Docuseal, draw.io, Etherpad, Excalidraw, Firefly III, Formbricks, Ghost, HedgeDoc, Hoarder, Homebox, IT-Tools, Joplin Server, Kimai, Kitchenowl, LanguageTool, LibreTranslate, Linkding, LinkStack, Linkwarden, Lychee, Mealie, Memos, Monica, OmniTools, OnlyOffice, Outline, Overleaf, Paperless Ai, Penpot, PrivateBin, Rallly, Reactive Resume, Readeck, Shlink, SiYuan, Snipe-IT, Stirling-PDF, Tandoor, Trilium, Twenty, Typebot, Vikunja, Wallabag, Web-Check, Wiki.js, Zipline |
| [VPN](./vpn/) | 3X-UI, Gluetun, Headplane, Headscale, NetBird, OpenVPN AS, Outline, Pritunl, SoftEther, WireGuard Easy, ZTNET |

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
9. Open required firewall ports via UFW (if installed)
10. Verify containers are running
11. Run a basic health check (HTTP/TCP/log-based)
12. Print access URL, credentials, and management tips

A few services with no public Docker image (Medusa, Payload, Faveo, GNU Health, IceHRM) build a local image from official sources — their first install takes several extra minutes.

---

## Repository Structure

```
.
├── 3d-printing/
├── accounting/
├── ai/
├── analytics/
├── automation/
├── backup/
├── cameras/
├── clinic/
├── cms/
├── communication/
├── crm/
├── databases/
├── dev/
├── downloads/
├── ecommerce/
├── education/
├── email/
├── erp/
├── files/
├── finance/
├── gaming/
├── hr/
├── iot/
├── low-code/
├── management/
├── media/
├── monitoring/
├── networking/
├── pos/
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
- Heavy stacks (TheHive, Taiga, MISP, ThingsBoard, UniFi) need 4–8 GB of RAM — check the service README before installing.
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
