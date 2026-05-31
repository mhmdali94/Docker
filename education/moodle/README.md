# Moodle — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

The world's most popular open-source Learning Management System — create online courses, quizzes, assignments, and certificates.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Moodle?

Moodle is the leading open-source LMS used by universities, schools, and businesses globally. It supports online courses with lessons, quizzes, assignments, forums, and discussion boards. Features include student enrollment, automated grading, certificates, SCORM/xAPI content, 1000+ plugins, and iOS/Android mobile apps.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/education/moodle/moodle-ubuntu.sh
chmod +x moodle-ubuntu.sh
sudo bash moodle-ubuntu.sh
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
| **Web UI** | `http://SERVER_IP:8083` |
| **Username** | Set during install |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address. First startup takes 3-5 minutes.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `8083` | TCP | Web UI |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/moodle/` | All service data and configuration |

---

## Management

```bash
# Follow logs
docker logs -f moodle

# Stop the service
cd /root/docker/moodle && docker compose down

# Start the service
cd /root/docker/moodle && docker compose up -d

# Update to latest image
cd /root/docker/moodle && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Minimum 2 GB RAM recommended
- Ports open in firewall: 8083/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
