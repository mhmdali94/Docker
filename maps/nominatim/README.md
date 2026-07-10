# Nominatim — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Nominatim](https://nominatim.org) — self-hosted geocoding — turn addresses into coordinates and back (powers OSM search).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/maps/nominatim/nominatim-ubuntu.sh
chmod +x nominatim-ubuntu.sh
sudo bash nominatim-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8318` | HTTP API |

## 💻 Connect

```bash
curl 'http://SERVER_IP:8318/search?q=monaco&format=json'
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
