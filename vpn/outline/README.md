# Outline VPN Server

Simple self-hosted Shadowsocks VPN by Google Jigsaw — managed via the Outline Manager desktop app.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/outline/outline-ubuntu.sh
sudo bash outline-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/outline/outline-ubuntu.sh | sudo bash
```

---

## 📖 What is Outline?

Outline is a self-hosted VPN tool developed by Google's Jigsaw team. It uses the Shadowsocks protocol and is designed to be simple to deploy and share. The server is managed via the Outline Manager desktop application and clients connect using the Outline client app.

## ✨ Features

- Simple access key sharing (one link per user)
- Data usage monitoring per key
- Works on Windows, macOS, Linux, Android, iOS
- Shadowsocks protocol (censorship-resistant)
- Managed via a desktop app (no web UI required)

## 🖥️ How to Manage

1. Install **Outline Manager** on your desktop: [getoutline.org](https://getoutline.org/get-started/#step-3)
2. Copy the **Management API URL** shown at the end of the install script
3. Paste it into Outline Manager to connect to your server
4. Create access keys and share them with users

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8092` | TCP | Management API |
| `12345` | TCP/UDP | VPN access keys |

## 📁 Directory Structure

```
/root/docker/outline/
├── docker-compose.yml
└── shadowbox-config/  # Server config & state
```

## 📚 Documentation

- [Outline GitHub](https://github.com/Jigsaw-Code/outline-server)
- [Outline Official Site](https://getoutline.org)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
