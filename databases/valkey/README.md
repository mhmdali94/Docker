# Valkey — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Valkey](https://valkey.io) — the Linux Foundation fork of Redis — drop-in compatible.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/valkey/valkey-ubuntu.sh
chmod +x valkey-ubuntu.sh
sudo bash valkey-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `6381` | Valkey (RESP) |

## 💻 Connect

```bash
valkey-cli -h SERVER_IP -p 6381 -a PASSWORD
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
