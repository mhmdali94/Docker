# Zulip — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Zulip](https://zulip.com/) — powerful open-source team chat with unique topic-based threading. Keeps conversations organized even in large, fast-moving teams — a self-hosted Slack alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/zulip/zulip-ubuntu.sh
chmod +x zulip-ubuntu.sh
sudo bash zulip-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Email | Auto-generated (shown at install) |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8585` | Zulip Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8585
```

## ⚙️ Notes

- Zulip takes ~3-5 minutes to start on first boot (database initialization)
- Use the generated admin credentials from the installer output
- Invite other users via Administration → Users → Invite users

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
