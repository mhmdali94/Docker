# Typesense — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Typesense](https://typesense.org) — a lightning-fast, typo-tolerant open-source search engine (Algolia alternative).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/typesense/typesense-ubuntu.sh
chmod +x typesense-ubuntu.sh
sudo bash typesense-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| API key | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8108` | HTTP API |

## 💻 Connect

```bash
curl http://SERVER_IP:8108/health
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
