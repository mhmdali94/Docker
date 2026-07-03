# ntopng — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ntopng](https://www.ntop.org) — real-time network traffic monitoring and analysis.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/ntopng/ntopng-ubuntu.sh
chmod +x ntopng-ubuntu.sh
sudo bash ntopng-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` (change on first login) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3051` | Web UI (host network) |

## 💻 Connect

```bash
http://SERVER_IP:3051
```

## 📝 Notes

- Runs with host networking to see real host traffic on all interfaces.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
