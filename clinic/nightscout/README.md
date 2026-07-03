# Nightscout — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Nightscout](https://nightscout.github.io) — remote CGM (continuous glucose monitor) monitoring — #WeAreNotWaiting.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/clinic/nightscout/nightscout-ubuntu.sh
chmod +x nightscout-ubuntu.sh
sudo bash nightscout-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| API secret | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8194` | Web UI + API |

## 💻 Connect

```bash
http://SERVER_IP:8194
```

## 📝 Notes

- Point your uploader (xDrip+, Loop, AAPS...) at this URL with the API secret.
- ⚠️ For informational use — never base medical decisions solely on this demo setup.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
