# Jitsi Meet

Self-hosted video conferencing. No accounts needed — share a link and start a meeting instantly.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/jitsi/jitsi-ubuntu.sh
chmod +x jitsi-ubuntu.sh
sudo bash jitsi-ubuntu.sh
```

## What It Installs

- **jitsi/web** — Web interface
- **jitsi/prosody** — XMPP signaling server
- **jitsi/jicofo** — Conference focus component
- **jitsi/jvb** — Video bridge (media relay)

## Ports

| Port | Service |
| --- | --- |
| 8080 | Web interface (HTTP) |
| 8443 | Web interface (HTTPS) |
| 10000/udp | Media (video/audio) |
| 4443/tcp | Media fallback |

## Access

| | URL |
| --- | --- |
| Jitsi Meet | `http://<server-ip>:8080` |

## Default Credentials

None — anyone can create a room. Set a room password inside the meeting if needed.

## Requirements

- **Public IP required** — Jitsi does not work reliably on LAN-only for remote participants (the JVB media bridge needs to be reachable)
- Minimum 2 GB RAM for small meetings, 4 GB+ recommended

## Notes

- The installer asks for your public IP or domain — this is critical for remote participants to connect
- For production, point a domain and enable HTTPS with Let's Encrypt
- Room passwords can be set by the moderator (first person in the room) during the call
- Recordings require the Jibri component (not included in this installer)
