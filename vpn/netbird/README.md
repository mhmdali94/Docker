# Netbird — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Netbird](https://netbird.io/) — a WireGuard-based mesh VPN with a self-hosted control plane. Includes a bundled **Dex OIDC** identity provider so login works out of the box with no external accounts required.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/netbird/netbird-ubuntu.sh
chmod +x netbird-ubuntu.sh
sudo bash netbird-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Email | `admin@netbird.local` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8089` | Netbird Web Dashboard |
| `8080` | Management API |
| `10000` | Signal Server |
| `5556` | Dex OIDC Identity Provider |

## 💻 Connect

```bash
# Web Dashboard
http://SERVER_IP:8089

# Connect a peer (after installing netbird client)
netbird up --management-url http://SERVER_IP:8080
```

## 🔐 How Authentication Works

This installer bundles **[Dex](https://dexidp.io/)** — a lightweight self-hosted OIDC provider — so you don't need Auth0, Google, or any external service to log in.

On first visit to the dashboard, click **Login** and you will be redirected to Dex. Enter the email and password shown at the end of the install.

## 📁 Directory Structure

```
/root/docker/netbird/
├── docker-compose.yml
├── dex/           # Dex OIDC config
├── signal/        # Signal server data
└── management/    # Management server data + management.json
```

## 📱 Install Netbird Client

Download from [netbird.io/downloads](https://netbird.io/downloads) and connect:

```bash
netbird up --management-url http://SERVER_IP:8080
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
