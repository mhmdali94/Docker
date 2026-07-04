# Docker Self-Hosted Services Collection

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Services](https://img.shields.io/badge/Services-481+-brightgreen)
![Categories](https://img.shields.io/badge/Categories-36-purple)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%20%7C%2024.04-orange)
![Made by](https://img.shields.io/badge/Made%20by-Mohammed%20Ali%20Elshikh-blue)

> ⚠️ **Scripts in this repository are provided for demo and testing purposes only and are not intended for production use.**

A growing collection of one-command Docker installer scripts for self-hosted services, organized by category. Each script handles Docker installation, credential generation, stack startup, and a basic health check — no manual configuration required.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## At a Glance

- **481+ services** across **36 categories**
- One-command install — just `wget` and `bash`
- Ubuntu 22.04 and 24.04 support
- Auto-installs Docker & Docker Compose V2 if missing
- Generates secure credentials on every run
- Clean reinstall — re-running removes the previous deployment
- Each service deploys under `/root/docker/<service>`
- Every Docker image is verified against its registry before release

---

## What's New — July 2026

- **250+ new services** added across four waves — including Apache Kafka, Cassandra, Hasura, Temporal, Concourse CI, LLDAP, OpenBao, Planka, Documenso, Owncast, AzuraCast, Homebridge, llama.cpp, InvokeAI, Crawl4AI, Supabase, Appwrite, Airflow, OpenSearch, Overleaf, Postiz and many more
- **Three new categories:** [Downloads](./downloads/), [Cameras](./cameras/) and [3D Printing](./3d-printing/)
- Every Docker image is registry-verified before release; host ports are collision-checked across the whole repo
- All existing scripts audited: dead images replaced, broken configs fixed (Hoarder migrated to its Karakeep successor)
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
| [3D Printing](./3d-printing/) | Manyfold, OctoPrint, Spoolman |
| [Accounting](./accounting/) | Akaunting, Invoice Ninja, InvoiceShelf |
| [AI](./ai/) | AnythingLLM, Chroma, ComfyUI, Crawl4AI, Dify, Docling, Flowise, InvokeAI, Kokoro TTS, Langflow, Langfuse, Letta, LibreChat, LiteLLM, llama.cpp, LobeChat, LocalAI, Milvus, MindsDB, Ollama, Open WebUI, Perplexica, Qdrant, SearXNG, SillyTavern, Speaches, Weaviate, Whisper |
| [Analytics](./analytics/) | Baserow, Lightdash, Matomo, Metabase, NocoDB, Plausible, Redash, Shynet, Superset, Swetrix, Umami |
| [Automation](./automation/) | ActivePieces, Apache Airflow, Automatisch, Huginn, Kestra, N8N, Node-RED, Semaphore, Windmill |
| [Backup](./backup/) | Backrest, Borgmatic, Duplicati, Kopia, Restic REST Server, UrBackup |
| [Cameras](./cameras/) | Frigate, go2rtc, Scrypted |
| [Clinic & Health](./clinic/) | Fasten Health, GNU Health, Nightscout, OpenEMR, OpenMRS, wger |
| [CMS](./cms/) | Directus, Drupal, Grav, Joomla, Payload, PocketBase, Strapi, WordPress |
| [Communication](./communication/) | Apprise, Chatwoot, ejabberd, Gotify, Jitsi, LiveKit, Matrix + Element, Mattermost, MiroTalk, Mumble, ntfy, RocketChat, Signal REST API, TeamSpeak, Zulip |
| [CRM](./crm/) | EspoCRM, SuiteCRM |
| [Databases](./databases/) | Adminer, Apache Kafka, ArangoDB, Cassandra, ClickHouse, CloudBeaver, CouchDB, DragonflyDB, Elasticsearch, FerretDB, InfluxDB, MariaDB, MeiliSearch, Memcached, MinIO, MongoDB, NATS, Neo4j, OpenSearch, pgAdmin, PostgreSQL, QuestDB, RabbitMQ, Redis, ScyllaDB, SurrealDB, TimescaleDB, Typesense, Valkey |
| [Dev](./dev/) | Appwrite, Atuin, Bytebase, Code-Server, Coder, Concourse CI, Coolify, Docker Registry, Dokploy, Flagsmith, Forgejo, Gitea, GitLab, Gitness, GlitchTip, Harbor, Hasura, Hoppscotch, Infisical, Jenkins, Judge0, LocalStack, Nexus, OneDev, Opengist, Plane, Sentry, SonarQube, Supabase, Temporal, Tolgee, Unleash, Verdaccio, Wakapi, Weblate, Woodpecker |
| [Downloads](./downloads/) | Aria2 + AriaNg, Deluge, MeTube, NZBGet, Pinchflat, qBittorrent, SABnzbd, slskd, Transmission |
| [Ecommerce](./ecommerce/) | Bagisto, EverShop, Medusa, PrestaShop, Saleor, Shopware |
| [Education](./education/) | Kolibri, Moodle |
| [Email](./email/) | addy.io, Docker Mailserver, Keila, Listmonk, Mailcow, Mailpit, Mailu, Mautic, Roundcube, SnappyMail, Stalwart |
| [ERP](./erp/) | Dolibarr, ERPNext, Grocy, iDempiere, InvenTree, Odoo 16, Odoo 17, Odoo 18, Part-DB, Tryton |
| [Files](./files/) | copyparty, FileBrowser, Filestash, Nextcloud, OpenCloud, PairDrop, Paperless-ngx, ProjectSend, Seafile, SeaweedFS, SFTPGo, Syncthing |
| [Finance](./finance/) | Ghostfolio, Maybe Finance, Wallos |
| [Gaming](./gaming/) | 7 Days to Die, ARK, Barotrauma, Core Keeper, Crafty Controller, CS2, Don't Starve Together, Enshrouded, Factorio, Foundry VTT, Garry's Mod, Left 4 Dead 2, Minecraft (Modded), Minecraft Bedrock, Minecraft Java, Minetest, OpenRA, OpenTTD, Palworld, Project Zomboid, Pterodactyl, Rust, Satisfactory, Team Fortress 2, Terraria, tModLoader, V Rising, Valheim, Vintage Story |
| [HR](./hr/) | Horilla, IceHRM, OrangeHRM |
| [IoT](./iot/) | Domoticz, EMQX, ESPHome, evcc, Home Assistant, Homebridge, Mosquitto, Music Assistant, openHAB, TeslaMate, ThingsBoard, Traccar, Z-Wave JS UI, Zigbee2MQTT |
| [Low-Code](./low-code/) | Appsmith, Budibase, NocoBase, Tooljet |
| [Management](./management/) | Dashy, Diun, Dockge, Glance, Homarr, Homepage, Komodo, Portainer, Watchtower, What's Up Docker, Yacht |
| [Media](./media/) | Audiobookshelf, AzuraCast, Bazarr, Calibre-Web, ErsatzTV, FreshRSS, Immich, Jellyfin, Jellyseerr, Jellystat, Kavita, Komga, LibrePhotos, Lidarr, Maintainerr, Miniflux, Navidrome, Overseerr, Owncast, PeerTube, PhotoPrism, Plex, Prowlarr, Radarr, Restreamer, RomM, RSS-Bridge, Sonarr, Stump, Suwayomi, Tautulli, Tdarr, Threadfin, TubeArchivist, Wizarr, Your Spotify |
| [Monitoring](./monitoring/) | Beszel, Cachet, Checkmk, Dozzle, Gatus, Glances, Grafana, Graylog, Healthchecks, Kener, LibreNMS, Loki, Netdata, ntopng, OpenObserve, Prometheus, Scrutiny, SigNoz, SmokePing, Speedtest Tracker, Uptime Kuma, VictoriaLogs, VictoriaMetrics, Zabbix |
| [Networking](./networking/) | AdGuard Home, Blocky, Caddy, Cloudflare DDNS, Cloudflared, FRP, HAProxy, LibreSpeed, NetAlertX, Nginx, Nginx Proxy Manager, Nginx UI, Omada Controller, Pi-hole, Tailscale, Technitium DNS, Traefik, Unbound, UniFi Controller, Zoraxy |
| [POS](./pos/) | OpenSourcePOS |
| [Project Management](./project-management/) | Kanboard, Leantime, OpenProject, Planka, Redmine, Taiga, WeKan |
| [Remote Access](./remote-access/) | Guacamole, Kasm, MeshCentral, Remotely, RustDesk, Sshwifty |
| [Security](./security/) | 2FAuth, Authelia, Authentik, CrowdSec, CyberChef, DefectDojo, Dependency-Track, Keycloak, LLDAP, MISP, NetBox, OpenBao, OpenVAS, OWASP ZAP, Passbolt, Password Pusher, Pocket ID, step-ca, TheHive, Trivy, Vault, Vaultwarden, Wazuh, Yopass, Zitadel |
| [Social](./social/) | Bluesky PDS, Flarum, GoToSocial, Lemmy, Mastodon, Misskey, NodeBB, Pixelfed, Postiz, WriteFreely |
| [Support](./support/) | Faveo, FreeScout, osTicket, Peppermint, Zammad |
| [Tools](./tools/) | Actual Budget, AFFiNE, ArchiveBox, Baby Buddy, Beaver Habits, BookStack, Cal.com, Changedetection, ConvertX, Dawarich, Docmost, Documenso, Docuseal, Donetick, draw.io, Easy!Appointments, Etherpad, Excalidraw, Fider, Firefly III, Formbricks, Ghost, HedgeDoc, Hoarder (Karakeep), Homebox, HortusFox, IT-Tools, Joplin Server, Kimai, KitchenOwl, LanguageTool, LibreTranslate, linkding, LinkStack, Linkwarden, Lychee, Mealie, Memos, MicroBin, Monica, OmniTools, OnlyOffice, Outline, Overleaf, Paperless-AI, Penpot, PrivateBin, Rallly, Reactive Resume, Readeck, Shlink, SiYuan, Snipe-IT, Stirling-PDF, Tandoor, Trilium, Twenty, Typebot, Vikunja, Wallabag, Web-Check, Wiki.js, Zipline |
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
