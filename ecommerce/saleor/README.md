# Saleor — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

High-performance headless e-commerce platform built on GraphQL — API-first architecture for any storefront.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Saleor?

Saleor is an open-source, API-first e-commerce platform built with Python and Django, exposing a full GraphQL API. It supports multi-channel, multi-currency, multi-warehouse, webhooks, and an app marketplace. Connect any storefront built with Next.js, React Native, or mobile apps to the commerce backend.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/saleor/saleor-ubuntu.sh
chmod +x saleor-ubuntu.sh
sudo bash saleor-ubuntu.sh
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
| **GraphQL API** | `http://SERVER_IP:8010/graphql/` |
| **Admin Dashboard** | `http://SERVER_IP:9001` |
| **Email** | `admin@saleor.local` |
| **Password** | Set on first dashboard login |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8010` | TCP | GraphQL API |
| `9001` | TCP | Admin Dashboard |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/saleor/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f saleor-api

# Stop the service
cd /root/docker/saleor && docker compose down

# Start the service
cd /root/docker/saleor && docker compose up -d

# Update to latest image
cd /root/docker/saleor && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8010/tcp, 9001/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
