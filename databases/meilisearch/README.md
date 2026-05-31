# Meilisearch — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Lightning-fast, typo-tolerant search engine — add full-text search to any app with a simple REST API.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Meilisearch?

Meilisearch is an open-source search engine designed for speed and relevance. It returns search results in under 50ms even on millions of documents, supports typo tolerance, faceted filtering, geosearch, and multi-tenant API keys. SDKs are available for JavaScript, Python, PHP, Go, Ruby, and more.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/meilisearch/meilisearch-ubuntu.sh
chmod +x meilisearch-ubuntu.sh
sudo bash meilisearch-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI / API** | `http://SERVER_IP:7700` |
| **Master Key** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. Use the Master Key in the `Authorization: Bearer` header for all API calls.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `7700` | TCP | REST API / Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/meilisearch/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f meilisearch

# Stop the service
cd /root/docker/meilisearch && docker compose down

# Start the service
cd /root/docker/meilisearch && docker compose up -d

# Update to latest image
cd /root/docker/meilisearch && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 7700/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
