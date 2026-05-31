# Syncthing — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Syncthing is a continuous, decentralized file synchronization tool that syncs files between two or more computers in real time without requiring a central server or cloud account.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Syncthing?

Syncthing transfers data directly between your devices using end-to-end encryption, with no files ever stored on a third-party server. It works across Linux, macOS, Windows, and Android. Ideal for keeping folders in sync between a server and multiple workstations or mobile devices without any cloud intermediary.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/syncthing/syncthing-ubuntu.sh
chmod +x syncthing-ubuntu.sh
sudo bash syncthing-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8384` |
| **Username** | Set via Actions → Settings → GUI |
| **Password** | Set via Actions → Settings → GUI |

> Replace `SERVER_IP` with your server's actual IP address. Set a GUI password immediately after first login.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8384` | TCP | Web UI |
| `22000` | TCP | Device sync (data transfer) |
| `22000` | UDP | Device sync (QUIC) |
| `21027` | UDP | Device discovery (local network) |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/syncthing/` | All service data and configuration |
| `/root/docker/syncthing/sync/` | Default sync folder |

---

## Management

```bash
# Follow logs
docker logs -f syncthing

# Stop
cd /root/docker/syncthing && docker compose down

# Start
cd /root/docker/syncthing && docker compose up -d

# Update to latest image
cd /root/docker/syncthing && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 8384/tcp, 22000/tcp, 22000/udp, 21027/udp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
