# Media Stack — One-Command Stack

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The complete home media server: **Jellyfin + Sonarr + Radarr + Prowlarr + qBittorrent + Jellyseerr** on one Docker network with one shared media library — install once, wire in minutes.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/stacks/media-stack/media-stack-ubuntu.sh
chmod +x media-stack-ubuntu.sh
sudo bash media-stack-ubuntu.sh
```

## 📦 What's inside

- **Jellyfin** — streaming server
- **Sonarr / Radarr** — TV & movie automation
- **Prowlarr** — indexer manager (syncs to both arrs)
- **qBittorrent** — download client
- **Jellyseerr** — request portal for your users

## 🌐 Ports

| Port | Service |
|------|---------|
| `8096` | Jellyfin |
| `8989` | Sonarr |
| `7878` | Radarr |
| `9696` | Prowlarr |
| `8115` | qBittorrent |
| `5056` | Jellyseerr |

## 🔗 Wiring

All containers resolve each other by name (`ms-sonarr`, `ms-qbittorrent`, ...) and share `./media` (`/media/movies`, `/media/tv`, `/media/downloads`). The install banner prints the 5-step connection checklist.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
