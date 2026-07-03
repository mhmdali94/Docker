# TeamSpeak Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [TeamSpeak Server](https://www.teamspeak.com) — the classic low-latency voice server for gaming communities.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/teamspeak/teamspeak-ubuntu.sh
chmod +x teamspeak-ubuntu.sh
sudo bash teamspeak-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin token | Shown in `docker logs teamspeak` on first start |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9987/udp` | Voice |
| `10011` | ServerQuery |
| `30033` | File transfer |

## 💻 Connect

```bash
TeamSpeak client → SERVER_IP:9987
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
