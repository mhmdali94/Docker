# Signal REST API — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Signal REST API](https://github.com/bbernhard/signal-cli-rest-api) — send and receive Signal messages over a REST API (great for alerts).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/signal-api/signal-api-ubuntu.sh
chmod +x signal-api-ubuntu.sh
sudo bash signal-api-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8225` | REST API |

## 💻 Connect

```bash
curl http://SERVER_IP:8225/v1/about
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
