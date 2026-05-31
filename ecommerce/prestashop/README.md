# PrestaShop — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Full-featured open-source e-commerce platform with product catalog, orders, payments, and multi-language/multi-currency support.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is PrestaShop?

PrestaShop is a popular open-source e-commerce platform used by over 300,000 online stores worldwide. It includes a complete product catalog, shopping cart, order management, customer accounts, payment and shipping integrations, and a powerful back-office administration panel. Supports 5000+ modules, 75+ payment gateways, multi-language, and multi-currency.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/prestashop/prestashop-ubuntu.sh
chmod +x prestashop-ubuntu.sh
sudo bash prestashop-ubuntu.sh
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
| **Store** | `http://SERVER_IP:8020` |
| **Admin Panel** | `http://SERVER_IP:8020/admin_panel` |
| **Email** | `admin@prestashop.local` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 2-4 minutes.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8020` | TCP | Store / Admin |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/prestashop/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f prestashop

# Stop the service
cd /root/docker/prestashop && docker compose down

# Start the service
cd /root/docker/prestashop && docker compose up -d

# Update to latest image
cd /root/docker/prestashop && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 8020/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
