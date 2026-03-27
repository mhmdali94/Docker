# Pi-hole

Network-wide ad blocker - blocks ads on all your devices.

## Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/pihole/pihole-ubuntu.sh
sudo bash pihole-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/pihole/pihole-ubuntu.sh | sudo bash
```

## What is Pi-hole?

Pi-hole is a DNS sinkhole that blocks ads and trackers at the network level. It acts as your DNS server and blocks known ad domains before they even reach your devices.

## Features

- Blocks ads on all devices (phones, TVs, computers, IoT)
- Works at the DNS level - no app installation needed
- Blocks trackers and malware domains
- Custom allowlists and blocklists
- Detailed statistics and query logging
- DHCP server capability
- Per-client reporting
- API for automation

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 53 | TCP/UDP | DNS server (required) |
| 80 | TCP | Web admin panel |

## Accessing Pi-hole

After installation:
- Admin panel: `http://SERVER_IP/admin`
- Default admin password is shown at the end of installation

## Setup Steps

1. Run the installer
2. Open `http://SERVER_IP/admin` in your browser
3. Login with the password shown during installation
4. Configure your devices or router to use Pi-hole as DNS

## Using Pi-hole as DNS

**Windows:**
```
Settings → Network → Change adapter settings → IPv4 → DNS: YOUR_SERVER_IP
```

**Mac:**
```
System Preferences → Network → Advanced → DNS → Add YOUR_SERVER_IP
```

**Router (recommended):**
Set DNS server to YOUR_SERVER_IP in your router settings to protect all devices.

**Android/iOS:**
```
Settings → WiFi → (i) on network → Configure DNS → Manual → Add YOUR_SERVER_IP
```

## Directory Structure

```
/root/docker/pihole/
├── docker-compose.yml
├── etc-pihole/          # Pi-hole configuration
└── etc-dnsmasq.d/       # DNS configuration
```

## Default Blocklists

Pi-hole comes with default blocklists that block:
- Advertising domains
- Tracking domains
- Malware domains

You can add more lists in the admin panel under **Group Management → Adlists**.

## Popular Blocklists

- StevenBlack's hosts
- OISD (Online International Server Domain)
- Firebog's lists

Add these in the admin panel for more comprehensive blocking.

## Changing Admin Password

```bash
docker exec -it pihole pihole -a -p
```

Or visit the admin panel → Settings → Web Interface → Web password.

## Updating Pi-hole

```bash
cd /root/docker/pihole
docker compose pull
docker compose up -d
```

## Useful Commands

```bash
# Check Pi-hole status
docker exec pihole pihole status

# Update blocklists
docker exec pihole pihole -g

# View logs
docker logs pihole

# Restart Pi-hole
docker restart pihole
```

## Troubleshooting

**Port 53 already in use:**
```bash
# Check what's using port 53
sudo lsof -i :53

# Disable systemd-resolved if needed
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

**Not blocking ads:**
- Check if DNS is set correctly on your device
- Clear DNS cache on your device
- Check query log in admin panel to see if queries are being processed

## Documentation

- [Pi-hole Official Site](https://pi-hole.net/)
- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Pi-hole GitHub](https://github.com/pi-hole/pi-hole)

## ⚠️ Disclaimer

This script is for **demo/testing purposes only**. Not intended for production use.

## Author

Made by: Mohammed Ali Elshikh | [prismatechwork.com](https://prismatechwork.com)
