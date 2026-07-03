# EverShop — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [EverShop](https://evershop.io) — a GraphQL-based Node.js e-commerce platform with a React storefront.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/evershop/evershop-ubuntu.sh
chmod +x evershop-ubuntu.sh
sudo bash evershop-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Created via `docker exec evershop npm run user:create -- --email ... --password ... --name Admin` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3048` | Storefront + admin |

## 💻 Connect

```bash
http://SERVER_IP:3048
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
