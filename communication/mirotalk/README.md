# MiroTalk P2P — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [MiroTalk P2P](https://p2p.mirotalk.com) — free WebRTC browser-based video calls — lighter than Jitsi.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/mirotalk/mirotalk-ubuntu.sh
chmod +x mirotalk-ubuntu.sh
sudo bash mirotalk-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3025` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:3025
```

## 📝 Notes

- Browsers only allow camera/microphone over HTTPS — put this behind Nginx Proxy Manager/Caddy with TLS for real use.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
