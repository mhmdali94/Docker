# WireGuard Easy

Self-hosted WireGuard VPN server with a simple, clean web UI to manage clients.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/wireguard-easy/wireguard-easy-ubuntu.sh
sudo bash wireguard-easy-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/wireguard-easy/wireguard-easy-ubuntu.sh | sudo bash
```

---

## 📖 What is WireGuard Easy?

WireGuard Easy (`wg-easy`) is the easiest way to run WireGuard VPN. It wraps WireGuard in a Docker container and provides a web UI to create, manage, and download client configuration files.

## ✨ Features

- One-click VPN client creation
- QR code generation for mobile clients
- Download `.conf` files for desktop clients
- Traffic statistics per client
- Enable/disable clients without deleting them
- Auto-detects your WAN IP

## 🌐 Access

| URL | `http://<server-ip>:51821` |
|-----|---------------------------|
| Password | Auto-generated during install (shown in terminal) |

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `51821` | TCP | Web UI |
| `51820` | UDP | WireGuard VPN tunnel |

> ⚠️ Make sure UDP port `51820` is open in your firewall for VPN connections to work.

## 📁 Directory Structure

```
/root/docker/wireguard-easy/
├── docker-compose.yml
└── data/          # WireGuard config & client keys
```

## 📚 Documentation

- [wg-easy GitHub](https://github.com/wg-easy/wg-easy)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
