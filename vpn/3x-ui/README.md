# 3X-UI — V2Ray / Xray Panel

A powerful web-based panel for managing V2Ray and Xray proxy protocols with a modern UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/3x-ui/3x-ui-ubuntu.sh
sudo bash 3x-ui-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/3x-ui/3x-ui-ubuntu.sh | sudo bash
```

---

## 📖 What is 3X-UI?

3X-UI is a multi-protocol proxy panel built on top of Xray-core. It supports a wide range of protocols and provides a web dashboard to manage inbound connections, users, and traffic limits.

## ✨ Features

- Supports VMess, VLESS, Trojan, Shadowsocks, Socks, HTTP, WireGuard
- User traffic monitoring and limits
- Subscription links for clients
- TLS & Reality support
- Multi-user management
- Uses host network mode for maximum compatibility

## 🌐 Access

| URL | `http://<server-ip>:2053` |
|-----|--------------------------|
| Username | Auto-generated during install (shown in terminal) |
| Password | Auto-generated during install (shown in terminal) |

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `2053` | TCP | Web panel UI |
| Custom | TCP/UDP | Inbound ports (configured in panel) |

## 📁 Directory Structure

```
/root/docker/3x-ui/
├── docker-compose.yml
├── db/            # Panel database
└── certs/         # TLS certificates
```

## 📚 Documentation

- [3X-UI GitHub](https://github.com/MHSanaei/3x-ui)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
