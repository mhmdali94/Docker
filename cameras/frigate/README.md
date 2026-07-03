# Frigate NVR — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Frigate NVR](https://frigate.video) — an NVR with real-time local AI object detection for IP cameras.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/cameras/frigate/frigate-ubuntu.sh
chmod +x frigate-ubuntu.sh
sudo bash frigate-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Shown in `docker logs frigate` on first start |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8971` | Web UI (authenticated) |
| `8554` | RTSP restreams |

## 💻 Connect

```bash
https://SERVER_IP:8971
```

## 📝 Notes

- Add your RTSP cameras in `config/config.yml` and restart.
- For AI acceleration add a Coral TPU or GPU passthrough — see Frigate docs.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
