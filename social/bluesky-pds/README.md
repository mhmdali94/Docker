# Bluesky PDS — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Bluesky PDS](https://github.com/bluesky-social/pds) — your own Bluesky Personal Data Server — own your identity and data on the AT Protocol.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/social/bluesky-pds/bluesky-pds-ubuntu.sh
chmod +x bluesky-pds-ubuntu.sh
sudo bash bluesky-pds-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3045` | PDS API |

## 💻 Connect

```bash
curl http://SERVER_IP:3045/xrpc/_health
```

## 📝 Notes

- Federation requires a real domain with a valid HTTPS certificate in front of the PDS.
- Create accounts via the admin API using the generated admin password.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
