# Audiobookshelf — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Audiobookshelf](https://www.audiobookshelf.org/) — a self-hosted audiobook and podcast server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/audiobookshelf/audiobookshelf-ubuntu.sh
chmod +x audiobookshelf-ubuntu.sh
sudo bash audiobookshelf-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin account | Created on first visit |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `13378` | Audiobookshelf Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:13378

# Add audiobooks to
/root/docker/audiobookshelf/audiobooks/

# Add podcasts to
/root/docker/audiobookshelf/podcasts/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
