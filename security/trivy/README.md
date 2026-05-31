# Trivy Server — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Trivy is a comprehensive vulnerability scanner for containers, filesystems, and infrastructure-as-code, running in server mode for centralized scanning from multiple clients.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Trivy?

Trivy (by Aqua Security) scans container images, filesystems, Git repositories, and IaC configurations for known CVEs, misconfigurations, and secrets. In server mode, it caches the vulnerability database centrally so clients can offload scanning without downloading the database themselves — ideal for CI/CD pipelines.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/trivy/trivy-ubuntu.sh
chmod +x trivy-ubuntu.sh
sudo bash trivy-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Starts the Trivy server (downloads vulnerability database on first run)
- Runs a health check

---

## Access

| | |
|---|---|
| **API Endpoint** | `http://SERVER_IP:4954` |
| **Username** | N/A — no authentication in this demo setup |
| **Password** | N/A |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `4954` | TCP | Trivy server API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/trivy/` | All service data and configuration |
| `/root/docker/trivy/cache/` | Vulnerability database cache |

---

## Scanning from a Client

```bash
# Scan a container image via the remote server
trivy image --server http://SERVER_IP:4954 nginx:latest

# Scan a local filesystem
trivy fs --server http://SERVER_IP:4954 /path/to/app
```

---

## Management

```bash
# Follow logs
docker logs -f trivy

# Stop
cd /root/docker/trivy && docker compose down

# Start
cd /root/docker/trivy && docker compose up -d

# Update to latest image
cd /root/docker/trivy && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Port 4954/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
