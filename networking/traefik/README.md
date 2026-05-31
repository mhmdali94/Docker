# Traefik — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Traefik is a modern cloud-native reverse proxy and load balancer that automatically discovers and routes traffic to Docker containers via labels.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is Traefik?

Traefik integrates natively with Docker and reads container labels to automatically configure routing rules, TLS termination, and middleware. It supports Let's Encrypt for automatic HTTPS, health checks, circuit breakers, and rate limiting. Its web dashboard provides a real-time view of all configured services and routers.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/traefik/traefik-ubuntu.sh
chmod +x traefik-ubuntu.sh
sudo bash traefik-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Writes a default `traefik.yaml` with Docker provider enabled
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Dashboard** | `http://SERVER_IP:8080/dashboard/#/` |
| **Username** | N/A — dashboard is open in this demo setup |
| **Password** | N/A |

> Replace `SERVER_IP` with your server's actual IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `80` | TCP | HTTP entry point |
| `443` | TCP | HTTPS entry point |
| `8080` | TCP | Dashboard / API |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/traefik/` | All service data and configuration |
| `/root/docker/traefik/traefik.yaml` | Main configuration file |
| `/root/docker/traefik/acme.json` | Let's Encrypt certificate storage (chmod 600) |

---

## Exposing a Service via Traefik

Add Docker labels to any container you want Traefik to route:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.example.com`)"
  - "traefik.http.routers.myapp.entrypoints=web"
```

---

## Management

```bash
# Follow logs
docker logs -f traefik

# Stop
cd /root/docker/traefik && docker compose down

# Start
cd /root/docker/traefik && docker compose up -d

# Update to latest image
cd /root/docker/traefik && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports 80/tcp, 443/tcp, and 8080/tcp open in firewall

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
