# NetAlertX — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [NetAlertX](https://netalertx.com) — presence detection and alerts for every device on your network (ex-PiAlert).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/netalertx/netalertx-ubuntu.sh
chmod +x netalertx-ubuntu.sh
sudo bash netalertx-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `20211` | Web UI (host network) |

## 💻 Connect

```bash
http://SERVER_IP:20211
```

## 📝 Notes

- Runs with host networking so it can ARP-scan your LAN.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
