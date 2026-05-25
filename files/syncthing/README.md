# Syncthing

Peer-to-peer file synchronization across devices — no cloud storage, no central server. Files sync directly between your devices.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/syncthing/syncthing-ubuntu.sh
chmod +x syncthing-ubuntu.sh
sudo bash syncthing-ubuntu.sh
```

## What It Installs

- **Syncthing** — P2P file sync daemon with web UI

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 8384 | TCP | Web UI |
| 22000 | TCP/UDP | Sync protocol |
| 21027 | UDP | Device discovery |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8384` |

## Default Credentials

No default credentials — set a GUI password immediately in **Actions → Settings → GUI**.

## Setup

1. Open the web UI and set a password
2. Note your **Device ID** (shown on the dashboard)
3. Install Syncthing on other devices (desktop, phone)
4. Add this server as a remote device using its Device ID
5. Share folders between devices

## Notes

- Sync folder on server: `./sync/` — add subfolders as needed
- Files are end-to-end encrypted in transit
- No central server — works on LAN or internet
- Desktop apps available for Windows, macOS, Linux, Android
- All devices must add each other mutually (security by design)
