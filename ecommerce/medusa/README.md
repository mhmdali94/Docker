# Medusa — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Open-source composable commerce platform — headless e-commerce backend with a React admin dashboard and REST API.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Medusa?

Medusa is an open-source, headless commerce engine built for developers. It provides a backend API for managing products, orders, customers, payments, and shipping alongside a React-based admin dashboard. Supports multi-region pricing, multi-currency, tax management, and payment integrations (Stripe, PayPal, Klarna) via plugins. Build your storefront with Next.js or any frontend framework.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/medusa/medusa-ubuntu.sh
chmod +x medusa-ubuntu.sh
sudo bash medusa-ubuntu.sh
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
| **API** | `http://SERVER_IP:9000` |
| **Admin Dashboard** | `http://SERVER_IP:7001` |
| **Authentication** | Create admin user after install |

> Replace `SERVER_IP` with your server's IP address. Create admin: `docker exec medusa medusa user -e admin@example.com -p yourpassword`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | Backend API |
| `7001` | TCP | Admin Dashboard |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/medusa/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f medusa

# Stop the service
cd /root/docker/medusa && docker compose down

# Start the service
cd /root/docker/medusa && docker compose up -d

# Update to latest image
cd /root/docker/medusa && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 9000/tcp, 7001/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
