# Headscale

Self-hosted open-source implementation of the Tailscale control server — use all Tailscale clients with your own server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

---

## 🚀 Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/vpn/headscale/headscale-ubuntu.sh
sudo bash headscale-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/vpn/headscale/headscale-ubuntu.sh | sudo bash
```

---

## 📖 What is Headscale?

Headscale is an open-source, self-hosted implementation of the Tailscale control server. It lets you run your own Tailscale-compatible network, using all official Tailscale clients (Windows, macOS, Linux, iOS, Android) while keeping full control of your data.

## ✨ Features

- Compatible with all official Tailscale clients
- Full mesh WireGuard network
- MagicDNS support
- Pre-authentication keys for easy onboarding
- User/namespace management
- Web UI via headscale-ui

## 🌐 Access

| Web UI | `http://<server-ip>:8091` |
|--------|--------------------------|
| API | `http://<server-ip>:8090` |

## 🔌 Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8090` | TCP | Headscale API & control server |
| `8091` | TCP | Headscale Web UI |

## ⚙️ Setup Steps

1. Run the installer
2. Create your first user:
```bash
docker exec headscale headscale users create myuser
```
3. Generate a pre-auth key:
```bash
docker exec headscale headscale preauthkeys create --user myuser
```
4. Connect a Tailscale client:
```bash
tailscale up --login-server http://<server-ip>:8090
```

## 📁 Directory Structure

```
/root/docker/headscale/
├── docker-compose.yml
├── config/
│   └── config.yaml    # Headscale configuration
├── data/              # Database & keys
└── run/               # Unix socket
```

## 📚 Documentation

- [Headscale GitHub](https://github.com/juanfont/headscale)
- [Headscale Documentation](https://headscale.net)

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
