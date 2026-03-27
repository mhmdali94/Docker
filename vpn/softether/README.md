# SoftEther VPN Server

Multi-protocol VPN server supporting L2TP/IPsec, SSTP, OpenVPN, and SoftEther protocol in one container.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/softether/softether-ubuntu.sh
sudo bash softether-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/softether/softether-ubuntu.sh | sudo bash
```

---

## 📖 What is SoftEther VPN?

SoftEther VPN is a free, open-source, cross-platform VPN server that supports multiple VPN protocols simultaneously. It is one of the most feature-rich self-hosted VPN solutions available.

## ✨ Features

- L2TP/IPsec — compatible with all native OS VPN clients
- SSTP — Microsoft's Secure Socket Tunneling Protocol
- OpenVPN — widely supported open protocol
- SoftEther — own high-performance protocol
- Built-in NAT traversal
- Managed via SoftEther VPN Server Manager (desktop app)

## 🖥️ How to Manage

Download and install **SoftEther VPN Server Manager** on your desktop:
- [softether-download.com](https://www.softether-download.com)

Then connect to your server at `<server-ip>:5555` to configure it.

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `5555` | TCP | SoftEther management |
| `443` | TCP | SSTP / SoftEther VPN |
| `1194` | UDP | OpenVPN |
| `500` | UDP | L2TP/IPsec (IKE) |
| `4500` | UDP | L2TP/IPsec (NAT-T) |
| `1701` | TCP | L2TP |

## ⚙️ Setup Steps

1. Run the installer
2. Download SoftEther VPN Server Manager on your desktop
3. Connect to `<server-ip>:5555`
4. Set an admin password on first connection
5. Create a Virtual Hub and add users
6. Configure L2TP/IPsec settings for client connections

## 📁 Directory Structure

```
/root/docker/softether/
├── docker-compose.yml
└── vpn_server.config  # SoftEther configuration
```

## 📚 Documentation

- [SoftEther VPN Project](https://www.softethervpn.org)
- [SoftEther GitHub](https://github.com/SoftEtherVPN/SoftEtherVPN)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
