# 🐳 Docker Self-Hosted Services Collection

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Services](https://img.shields.io/badge/Services-29-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%20%7C%2024.04-orange)

A collection of one-command Docker installer scripts for the most popular self-hosted services — organized by category.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

> ⚠️ Scripts in this repository are provided for **demo and testing purposes only** and are not intended for production use.

---

## 📂 Categories

| Category | Services |
|----------|---------|
| [🔒 VPN](#-vpn) | 8 services |
| [📧 Email](#-email) | 3 services |
| [🎬 Media](#-media) | 2 services |
| [📊 Monitoring](#-monitoring) | 3 services |
| [🌐 Networking](#-networking) | 3 services |
| [🖥️ Remote Access](#️-remote-access) | 3 services |
| [🗄️ Databases](#️-databases) | 2 services |
| [🔐 Security](#-security) | 1 service |
| [📁 Files](#-files) | 1 service |
| [🛠️ Tools](#️-tools) | 2 services |
| [⚙️ Management](#️-management) | 1 service |

---

## 🔒 VPN

| Service | Description | Port(s) |
|---------|-------------|---------|
| [WireGuard Easy](./vpn/wireguard-easy/) | WireGuard VPN with a clean web UI — create and manage clients via browser | `51821` UI, `51820/UDP` VPN |
| [3X-UI](./vpn/3x-ui/) | Xray/V2Ray multi-protocol panel supporting VMess, VLESS, Trojan, Shadowsocks | `2053` |
| [OpenVPN AS](./vpn/openvpn-as/) | Official OpenVPN Access Server with admin panel and client portal | `943`, `443`, `1194` |
| [Pritunl](./vpn/pritunl/) | Enterprise-grade OpenVPN + WireGuard server with polished web dashboard | `80`, `443`, `1194` |
| [Netbird](./vpn/netbird/) | WireGuard mesh VPN that works behind NAT — no port forwarding needed | `8089` UI, `8080` API |
| [Headscale](./vpn/headscale/) | Self-hosted Tailscale control server — use all Tailscale clients with your own server | `8090` API, `8091` UI |
| [Outline](./vpn/outline/) | Simple Shadowsocks VPN by Google Jigsaw — managed via Outline Manager desktop app | `8092`, `12345` |
| [SoftEther](./vpn/softether/) | Multi-protocol VPN supporting L2TP/IPsec, SSTP, OpenVPN and SoftEther in one server | `5555`, `443`, `1194` |

---

## 📧 Email

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Mailcow](./email/mailcow/) | Complete email suite — Postfix, Dovecot, SOGo webmail, Rspamd antispam, and ClamAV | `80`, `443`, `25`, `587`, `143` |
| [Mailu](./email/mailu/) | Simple full email stack with Roundcube webmail, Rspamd, and a clean admin panel | `80`, `443`, `25`, `587`, `143` |
| [Listmonk](./email/listmonk/) | High-performance newsletter and mailing list manager — requires external SMTP | `9000` |

---

## 🎬 Media

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Jellyfin](./media/jellyfin/) | Free open-source media server for movies, TV, music, and photos — no subscription needed | `8096` |
| [Navidrome](./media/navidrome/) | Modern self-hosted music streaming server compatible with Subsonic/Airsonic clients | `4533` |

---

## 📊 Monitoring

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Uptime Kuma](./monitoring/uptime-kuma/) | Beautiful self-hosted uptime and status page monitor for websites and services | `3001` |
| [Beszel](./monitoring/beszel/) | Lightweight server monitoring hub with agents for multi-server tracking | `8090` |
| [Netdata](./monitoring/netdata/) | Real-time performance and health monitoring with hundreds of built-in metrics | host network |

---

## 🌐 Networking

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Nginx Proxy Manager](./networking/npm/) | Reverse proxy with a web UI for managing domains, SSL certificates, and forwarding rules | `80`, `81`, `443` |
| [AdGuard Home](./networking/adguardhome/) | Network-wide DNS ad and tracker blocker — protects all devices on your network | `53`, `8083`, `3000` |
| [Pi-hole](./networking/pihole/) | DNS-based network ad blocker with a built-in dashboard and query log | `53`, `8084` |

---

## 🖥️ Remote Access

| Service | Description | Port(s) |
|---------|-------------|---------|
| [RustDesk](./remote-access/rustdesk/) | Self-hosted remote desktop server — relay and ID server for RustDesk clients | `21115–21119` |
| [Guacamole](./remote-access/guacamole/) | Clientless remote desktop gateway supporting RDP, VNC, and SSH from any browser | `8085` |
| [Remotely](./remote-access/remotely/) | Browser-based remote desktop support tool for managing remote computers | `5000` |

---

## 🗄️ Databases

| Service | Description | Port(s) |
|---------|-------------|---------|
| [PostgreSQL](./databases/postgres/) | Powerful open-source relational database — auto-generated credentials on install | `5432` |
| [Redis](./databases/redis/) | Fast in-memory key-value store used for caching and queues — password protected | `6379` |

---

## 🔐 Security

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Vaultwarden](./security/vaultwarden/) | Lightweight self-hosted Bitwarden-compatible password manager — works with all Bitwarden clients | `8086` |

---

## 📁 Files

| Service | Description | Port(s) |
|---------|-------------|---------|
| [FileBrowser](./files/filebrowser/) | Clean web-based file manager for browsing, uploading, and managing server files | `8082` |

---

## 🛠️ Tools

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Stirling-PDF](./tools/stirling-pdf/) | 50+ PDF tools in one self-hosted app — merge, split, compress, convert, OCR, and more | `8087` |
| [IT-Tools](./tools/it-tools/) | 100+ developer utilities — UUID, JWT, hash, base64, cron parser, QR code, and more | `8088` |

---

## ⚙️ Management

| Service | Description | Port(s) |
|---------|-------------|---------|
| [Portainer CE](./management/portainer/) | Web UI for managing Docker containers, images, volumes, and networks | `9443`, `8000` |

---

## 📋 Requirements

- Ubuntu `22.04` or `24.04`
- Root / sudo access
- Docker & Docker Compose V2 (auto-installed by scripts if missing)
- Open firewall ports as required per service

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
