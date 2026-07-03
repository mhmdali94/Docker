# OctoPrint — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [OctoPrint](https://octoprint.org) — the snappy web interface for your 3D printer.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/3d-printing/octoprint/octoprint-ubuntu.sh
chmod +x octoprint-ubuntu.sh
sudo bash octoprint-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8231` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8231
```

## 📝 Notes

- Add your printer's USB device under `devices:` in docker-compose.yml and restart.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
