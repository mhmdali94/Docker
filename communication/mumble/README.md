# Mumble Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Mumble Server](https://www.mumble.info) — low-latency VoIP for gaming and teams.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/mumble/mumble-ubuntu.sh
chmod +x mumble-ubuntu.sh
sudo bash mumble-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Server password | Auto-generated (shown at install) |
| SuperUser password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `64738` | Voice TCP/UDP |

## 💻 Connect

```bash
Mumble client → Add Server → SERVER_IP:64738
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
