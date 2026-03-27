# Netbird

WireGuard-based mesh VPN that connects your devices into a secure private network — even behind NAT.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/netbird/netbird-ubuntu.sh
sudo bash netbird-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/netbird/netbird-ubuntu.sh | sudo bash
```

---

## 📖 What is Netbird?

Netbird is a WireGuard-based mesh VPN that creates a peer-to-peer private network between your devices. It works behind NAT and firewalls without requiring port forwarding, making it ideal for connecting remote devices securely.

## ✨ Features

- Zero-config peer-to-peer WireGuard tunnels
- Works behind NAT without port forwarding
- Web dashboard for peer management
- Access control policies
- Works on Linux, macOS, Windows, Android, iOS
- Self-hosted control plane (signal + management servers)

## 🌐 Access

| Dashboard | `http://<server-ip>:8089` |
|-----------|--------------------------|
| Management API | `http://<server-ip>:8080` |
| Signal Server | `<server-ip>:10000` |

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8089` | TCP | Web dashboard |
| `8080` | TCP | Management API |
| `10000` | TCP | Signal server |

## 📱 Connect a Peer

Install the Netbird client on any device and point it to your server:
```bash
netbird up --management-url http://<server-ip>:8080
```

Download clients at: [netbird.io/downloads](https://netbird.io/downloads)

## 📁 Directory Structure

```
/root/docker/netbird/
├── docker-compose.yml
├── signal/        # Signal server data
└── management/    # Management server data
```

## 📚 Documentation

- [Netbird Documentation](https://docs.netbird.io)
- [Netbird GitHub](https://github.com/netbirdio/netbird)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
