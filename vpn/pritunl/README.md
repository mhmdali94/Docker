# Pritunl

Enterprise-grade self-hosted VPN server supporting OpenVPN and WireGuard with a polished web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/pritunl/pritunl-ubuntu.sh
sudo bash pritunl-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/pritunl/pritunl-ubuntu.sh | sudo bash
```

---

## 📖 What is Pritunl?

Pritunl is a powerful self-hosted VPN server with a clean web dashboard. It supports OpenVPN and WireGuard protocols and is one of the most popular open-source VPN solutions for teams and enterprises.

## ✨ Features

- OpenVPN and WireGuard support
- Multi-user and multi-organization management
- Two-factor authentication (2FA)
- User groups and access policies
- Client auto-configuration download
- Built-in MongoDB for storage

## 🌐 Access

| URL | `https://<server-ip>` |
|-----|-----------------------|

**To get your setup key and default credentials, run:**
```bash
docker exec pritunl pritunl setup-key
docker exec pritunl pritunl default-password
```

> ⚠️ Accept the self-signed SSL certificate in your browser.

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP (redirects to HTTPS) |
| `443` | TCP | Web UI + VPN tunnel |
| `1194` | TCP/UDP | OpenVPN tunnel |

## 📁 Directory Structure

```
/root/docker/pritunl/
├── docker-compose.yml
├── data/          # Pritunl data
└── mongo/         # MongoDB data
```

## 📚 Documentation

- [Pritunl Documentation](https://docs.pritunl.com)
- [Pritunl GitHub](https://github.com/pritunl/pritunl)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
