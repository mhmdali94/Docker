# ejabberd — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [ejabberd](https://www.ejabberd.im) — the battle-tested scalable XMPP (Jabber) server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/ejabberd/ejabberd-ubuntu.sh
chmod +x ejabberd-ubuntu.sh
sudo bash ejabberd-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Created via `docker exec ejabberd ejabberdctl register admin <host> <password>` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5222` | XMPP clients |
| `5269` | Server-to-server |
| `5281` | Web admin |
| `5444` | File upload/BOSH TLS |

## 💻 Connect

```bash
XMPP client → SERVER_IP:5222
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
