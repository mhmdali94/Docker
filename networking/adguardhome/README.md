# AdGuard Home

Network-wide ad & tracker blocker that works at the DNS level.

## Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/adguardhome/adguardhome-ubuntu.sh
sudo bash adguardhome-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/adguardhome/adguardhome-ubuntu.sh | sudo bash
```

## What is AdGuard Home?

AdGuard Home is a network-wide ad and tracker blocking DNS server. It blocks ads, trackers, and malicious domains before they even load on your devices.

## Features

- Blocks ads on all devices (phones, TVs, IoT, computers)
- Works at the DNS level (no app installation needed)
- Privacy protection (blocks trackers)
- Faster page loading
- Parental controls
- Custom filtering rules
- Encrypted DNS support (DoH/DoT)

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 53 | TCP/UDP | DNS server (required) |
| 80 | TCP | Web admin panel (after setup) |
| 443 | TCP/UDP | HTTPS/DNS-over-HTTPS |
| 3000 | TCP | Initial setup wizard |

## Setup Steps

1. Run the installer
2. Open `http://SERVER_IP:3000` in your browser
3. Complete the setup wizard
4. Set AdGuard Home as your DNS server on your devices or router

## Using as DNS Server

After setup, configure your devices to use your server's IP as the DNS:

**Windows:**
```
Settings → Network → Change adapter settings → IPv4 → DNS: YOUR_SERVER_IP
```

**Mac:**
```
System Preferences → Network → Advanced → DNS → Add YOUR_SERVER_IP
```

**Router (recommended):**
Set DNS server to YOUR_SERVER_IP in your router settings to protect all devices on your network.

## Directory Structure

```
/root/docker/adguardhome/
├── docker-compose.yml
├── work/          # Working directory
└── conf/          # Configuration files
```

## Default Upstream DNS

After installation, you can configure upstream DNS servers like:
- `94.140.14.14` (AdGuard DNS)
- `1.1.1.1` (Cloudflare)
- `8.8.8.8` (Google)

## Web Admin Panel

After initial setup, access the admin panel at:
```
http://YOUR_SERVER_IP
```

## Documentation

- [AdGuard Home GitHub](https://github.com/AdguardTeam/AdGuardHome)
- [Official Wiki](https://github.com/AdguardTeam/AdGuardHome/wiki)

## ⚠️ Disclaimer

This script is for **demo/testing purposes only**. Not intended for production use.

## Author

Made by: Mohammed Ali Elshikh | [prismatechwork.com](https://prismatechwork.com)
