# Your Spotify — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Your Spotify](https://github.com/Yooooomi/your_spotify) — your personal Spotify listening statistics dashboard.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/your-spotify/your-spotify-ubuntu.sh
chmod +x your-spotify-ubuntu.sh
sudo bash your-spotify-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3058` | Web UI |
| `8218` | API |

## 💻 Connect

```bash
http://SERVER_IP:3058
```

## 📝 Notes

- Requires a free Spotify developer application (client ID + secret).
- Redirect URI must be `http://SERVER_IP:8218/oauth/spotify/callback`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
