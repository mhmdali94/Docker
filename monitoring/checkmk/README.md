# Checkmk — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Checkmk](https://checkmk.com) — comprehensive IT infrastructure monitoring (Raw/open-source edition).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/checkmk/checkmk-ubuntu.sh
chmod +x checkmk-ubuntu.sh
sudo bash checkmk-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `cmkadmin` |
| Password | Shown in `docker logs checkmk` on first start |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8136` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8136/cmk/
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
