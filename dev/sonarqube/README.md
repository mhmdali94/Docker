# SonarQube — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Leading open-source platform for static code analysis and security scanning across 30+ programming languages.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is SonarQube?

SonarQube is the industry-standard platform for continuous code quality and security inspection. It performs static application security testing (SAST), detects bugs, code smells, and vulnerabilities across 30+ languages including Java, JavaScript, Python, C#, Go, and PHP. Integrates with GitHub, GitLab, Jenkins, and Azure DevOps CI/CD pipelines.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/sonarqube/sonarqube-ubuntu.sh
chmod +x sonarqube-ubuntu.sh
sudo bash sonarqube-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:9000` |
| **Username** | `admin` |
| **Password** | `admin` (forced change on first login) |

> Replace `SERVER_IP` with your server's IP address. First startup takes ~2 minutes for Elasticsearch initialization.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | Web UI / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/sonarqube/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f sonarqube

# Stop the service
cd /root/docker/sonarqube && docker compose down

# Start the service
cd /root/docker/sonarqube && docker compose up -d

# Update to latest image
cd /root/docker/sonarqube && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 9000/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
