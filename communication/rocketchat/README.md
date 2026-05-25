# Rocket.Chat

Self-hosted team messaging and collaboration platform. A Slack alternative with channels, DMs, video calls, and a marketplace of integrations.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/rocketchat/rocketchat-ubuntu.sh
chmod +x rocketchat-ubuntu.sh
sudo bash rocketchat-ubuntu.sh
```

## What It Installs

- **Rocket.Chat** — Team messaging platform
- **MongoDB 5.0** — Database with replica set

## Ports

| Port | Service |
| --- | --- |
| 3100 | Rocket.Chat web interface |

## Access

| | URL |
| --- | --- |
| Rocket.Chat | `http://<server-ip>:3100` |

## Default Credentials

No default credentials — the first user to register becomes the admin.

## Notes

- Requires MongoDB with replica set enabled (configured automatically)
- First startup takes ~60 seconds for replica set initialization
- Supports LDAP, SAML, OAuth for enterprise authentication
- Mobile apps available for iOS and Android
- Minimum 2 GB RAM recommended
