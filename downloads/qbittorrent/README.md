# qBittorrent — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [qBittorrent](https://www.qbittorrent.org) — a feature-rich BitTorrent client with WebUI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/downloads/qbittorrent/qbittorrent-ubuntu.sh
chmod +x qbittorrent-ubuntu.sh
sudo bash qbittorrent-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Temporary password printed in `docker logs qbittorrent` — change it in WebUI settings |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8115` | WebUI |
| `6881` | BitTorrent TCP/UDP |

## 💻 Connect

```bash
http://SERVER_IP:8115
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
