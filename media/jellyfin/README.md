# Jellyfin

Free and open-source media server — stream your movies, TV shows, music, and photos anywhere.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/media/jellyfin/jellyfin-ubuntu.sh
sudo bash jellyfin-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/media/jellyfin/jellyfin-ubuntu.sh | sudo bash
```

---

## 📖 What is Jellyfin?

Jellyfin is a free, open-source alternative to Plex and Emby. It lets you collect, manage, and stream your media from your own server to any device — with no subscription fees, no tracking, and no cloud required.

## ✨ Features

- Stream movies, TV shows, music, photos, and live TV
- Supports all major formats (MKV, MP4, AVI, etc.)
- Hardware-accelerated transcoding (Intel, NVIDIA, AMD)
- Multi-user with individual libraries and parental controls
- Native apps for Android, iOS, Apple TV, Roku, Fire TV, web browser
- DLNA and Chromecast support
- No subscription required — 100% free

## 🌐 Access

| URL | `http://<server-ip>:8096` |
|-----|--------------------------|

On first visit, complete the setup wizard to create your admin account and add media libraries.

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8096` | TCP | Jellyfin Web UI |

## 📁 Adding Media

Place your media files in:
```
/root/docker/jellyfin/media/
```

Then add it as a library inside Jellyfin's setup wizard or Dashboard → Libraries.

## 📁 Directory Structure

```
/root/docker/jellyfin/
├── docker-compose.yml
├── config/        # Jellyfin configuration & metadata
├── cache/         # Transcoding cache
└── media/         # Your media files
```

## 📚 Documentation

- [Jellyfin Documentation](https://jellyfin.org/docs)
- [Jellyfin GitHub](https://github.com/jellyfin/jellyfin)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
