# Blocky — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Blocky](https://0xerr0r.github.io/blocky/) — a fast, lightweight DNS proxy with ad/tracker blocking (Pi-hole alternative, single binary).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/blocky/blocky-ubuntu.sh
chmod +x blocky-ubuntu.sh
sudo bash blocky-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5354` | DNS TCP/UDP |
| `4002` | HTTP API |

## 💻 Connect

```bash
dig @SERVER_IP -p 5354 example.com
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
