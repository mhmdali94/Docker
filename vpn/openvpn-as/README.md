# OpenVPN Access Server

Official OpenVPN Access Server with a full web UI for managing VPN users and connections.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/openvpn-as/openvpn-as-ubuntu.sh
sudo bash openvpn-as-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/openvpn-as/openvpn-as-ubuntu.sh | sudo bash
```

---

## 📖 What is OpenVPN Access Server?

OpenVPN Access Server is the official self-hosted OpenVPN solution. It includes a web admin UI, a client portal for downloading VPN profiles, and supports up to 2 simultaneous VPN connections on the free tier.

## ✨ Features

- Web-based admin panel and client portal
- Auto-generates VPN client config files
- Supports Windows, macOS, Linux, Android, iOS clients
- Certificate-based authentication
- User and group management
- Free tier: up to 2 VPN connections

## 🌐 Access

| Admin UI | `https://<server-ip>:943/admin` |
|----------|---------------------------------|
| Client Portal | `https://<server-ip>:943` |
| Username | `openvpn` |
| Password | Set it by running: `docker exec -it openvpn-as passwd openvpn` |

> ⚠️ Accept the self-signed SSL certificate in your browser.

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `943` | TCP | Web admin UI & client portal |
| `443` | TCP | VPN tunnel (TCP) |
| `1194` | UDP | VPN tunnel (UDP) |

## 📁 Directory Structure

```
/root/docker/openvpn-as/
├── docker-compose.yml
└── data/          # OpenVPN config & certificates
```

## 📚 Documentation

- [OpenVPN Access Server Docs](https://openvpn.net/access-server-manual/)
- [Docker Hub](https://hub.docker.com/r/openvpn/openvpn-as)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
