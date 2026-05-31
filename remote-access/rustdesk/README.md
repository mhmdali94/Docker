# RustDesk Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

RustDesk Server is the self-hosted relay and signaling backend for the RustDesk open-source remote desktop client.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is RustDesk Server?

RustDesk is an open-source TeamViewer alternative. This installer sets up the server-side components: `hbbs` (ID/signaling server) and `hbbr` (relay server). RustDesk clients are configured to use your self-hosted server instead of the public RustDesk infrastructure, keeping all remote access traffic on your own infrastructure.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/remote-access/rustdesk/rustdesk-ubuntu.sh
chmod +x rustdesk-ubuntu.sh
sudo bash rustdesk-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Prompts for your server's public IP or domain
- Starts the hbbs and hbbr containers
- Retrieves and displays the server's public key

---

## Access

| | |
|---|---|
| **Web UI** | N/A — configure via RustDesk client app |
| **Server Address** | Your server's public IP or domain |
| **Public Key** | Auto-generated and displayed in terminal |

Configure the RustDesk client under **Settings → Network → ID/Relay Server**:
- ID Server: `SERVER_IP`
- Relay Server: `SERVER_IP`
- Key: `<public key displayed in terminal>`

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `21115` | TCP | NAT type test |
| `21116` | TCP/UDP | ID server / hole punching |
| `21117` | TCP | Relay server |
| `21118` | TCP | WebSocket (hbbs) |
| `21119` | TCP | WebSocket (hbbr) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/rustdesk/` | All service data and configuration |
| `/root/docker/rustdesk/hbbs/` | ID server data and key files |
| `/root/docker/rustdesk/hbbr/` | Relay server data |

---

## Management

```bash
# Follow logs
docker logs -f hbbs
docker logs -f hbbr

# Stop
cd /root/docker/rustdesk && docker compose down

# Start
cd /root/docker/rustdesk && docker compose up -d

# Update to latest image
cd /root/docker/rustdesk && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 21115–21119/tcp and 21116/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
