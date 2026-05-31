# DefectDojo — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

DefectDojo is an open-source application vulnerability management platform for tracking security findings across products and engagements.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is DefectDojo?

DefectDojo is a DevSecOps and vulnerability management tool that aggregates findings from security scanners (Burp Suite, OWASP ZAP, Nessus, etc.), tracks remediation progress, and generates compliance reports. It supports deduplication, SLA tracking, risk scoring, and integrates with CI/CD pipelines.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/defectdojo/defectdojo-ubuntu.sh
chmod +x defectdojo-ubuntu.sh
sudo bash defectdojo-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the full DefectDojo stack
- Runs a health check (may take ~3 minutes)

---

## Access

| | |
|---|---|
| **Web UI** | `http://SERVER_IP:8092` |
| **Username** | `admin` |
| **Password** | Auto-generated during install (displayed in terminal) |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8092` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/defectdojo/` | All service data and configuration |
| `/root/docker/defectdojo/media/` | Uploaded reports and media |

---

## Management

```bash
# Follow logs
docker logs -f defectdojo

# Stop
cd /root/docker/defectdojo && docker compose down

# Start
cd /root/docker/defectdojo && docker compose up -d

# Update to latest image
cd /root/docker/defectdojo && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 8092/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
