# CrowdSec — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

CrowdSec is a collaborative, open-source security engine that analyzes logs and blocks malicious IPs using a shared community threat intelligence feed.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is CrowdSec?

CrowdSec parses system and application logs, detects attack patterns (brute force, scanning, exploitation), and can share anonymized threat intelligence with the CrowdSec community. Bouncers integrate with firewalls and reverse proxies to automatically block detected attackers. It is designed to complement existing security tools.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/crowdsec/crowdsec-ubuntu.sh
chmod +x crowdsec-ubuntu.sh
sudo bash crowdsec-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts CrowdSec with SSH and Linux collections pre-loaded
- Generates a bouncer API key
- Runs a health check

---

## Access

| | |
|---|---|
| **Metrics** | `http://SERVER_IP:6060/metrics` |
| **Local API** | `http://SERVER_IP:8181` |
| **Username** | N/A — API key based |
| **Bouncer API Key** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `6060` | TCP | Metrics endpoint |
| `8181` | TCP | Local API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/crowdsec/` | All service data and configuration |
| `/root/docker/crowdsec/data/` | CrowdSec database |
| `/root/docker/crowdsec/config/` | Configuration files |

---

## Useful Commands

```bash
# View current alerts
docker exec crowdsec cscli alerts list

# Add a bouncer
docker exec crowdsec cscli bouncers add my-bouncer

# View decisions (blocked IPs)
docker exec crowdsec cscli decisions list
```

---

## Management

```bash
# Follow logs
docker logs -f crowdsec

# Stop
cd /root/docker/crowdsec && docker compose down

# Start
cd /root/docker/crowdsec && docker compose up -d

# Update to latest image
cd /root/docker/crowdsec && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 6060/tcp and 8181/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
