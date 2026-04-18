# Script Development Guide

This document covers how to build new installer scripts for this repo, following the established patterns and conventions.

---

## Directory Structure

Each service lives in its own folder under a category:

```
category/service-name/
├── service-name-ubuntu.sh   ← installer script
└── README.md                ← usage & credentials doc
```

**Current categories:** `analytics`, `backup`, `communication`, `databases`, `dev`, `email`, `files`, `management`, `media`, `monitoring`, `networking`, `remote-access`, `security`, `tools`, `vpn`

---

## Script Skeleton

Every script follows this exact step order:

```bash
#!/bin/bash
# ============================================================
#   [Service] Auto-Installer
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================

set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

# --- Banners (opening + demo warning + ENTER prompt) ---

section "Step 0: Checking Privileges"      # EUID check
section "Step 1: Verifying OS"             # Ubuntu 22.04/24.04 only
section "Step 2: Checking Docker"          # install if missing
section "Step 3: Checking Docker Compose V2"
section "Step 4: Cleaning Up Existing Containers"
section "Step 5: Preparing Directory"      # rm -rf + mkdir
section "Step 6: Generating ..."           # credentials + docker-compose.yml
section "Step 7: Starting [Service]"       # docker compose up -d
section "Step 8: Opening Firewall Port N"  # ufw allow — ALWAYS before verify
section "Step 9: Verifying Container"      # docker ps check
section "Step 10: Health Check"            # curl/nc loop

# --- Final success banner ---
```

---

## Rules

### Firewall Step Order
**Always place the firewall step (UFW) BEFORE the verify and health check steps.**

```bash
section "Step 8: Opening Firewall Port XXXX"   ← Step 8
section "Step 9: Verifying Container"           ← Step 9
section "Step 10: Health Check"                 ← Step 10
```

This matches the Navidrome fix pattern. Placing firewall after health check causes the health check to run on a closed port in environments where UFW blocks loopback — open the port first.

### Step 4: Cleanup (Standard Pattern for ALL Scripts)

Step 4 must always do a **full teardown** — containers, image (if locally built), and config directory — so re-running the script always produces a clean fresh install.

```bash
section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/service-name"

# 1. Remove existing containers
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E 'service-name' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
    info "Containers removed."
else
    info "No existing containers found."
fi

# 2. Remove local image (only for scripts that use docker build)
if docker image inspect service-local &>/dev/null 2>&1; then
    warn "Removing existing service-local image..."
    docker rmi -f service-local 2>/dev/null || true
    info "Image removed."
fi

# 3. Remove config directory (wipes database, credentials, compose file)
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
    info "Configuration removed."
fi

docker network prune -f &>/dev/null || true
```

**Rules:**
- Always remove containers **before** the directory so Docker doesn't hold file locks
- Only include the image removal block if the script uses `docker build` (local image)
- For registry-pulled images, skip the `docker image inspect` block — the image is cached and reusable
- `docker network prune -f` cleans up orphaned networks left by previous runs

### Directory Setup
```bash
section "Step 5: Preparing Directory"
mkdir -p "$SERVICE_DIR"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"
```

Note: `SERVICE_DIR` is defined in Step 4 so it's available here without repeating the path.

### Credential Generation
```bash
DB_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9!@#$%' < /dev/urandom | head -c 20)
SECRET_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
```

Always print generated credentials with `info` before writing docker-compose.yml so the user can save them.

### Docker Images — Registry Priority
Pull images in this order of preference (most reliable first):

| Priority | Registry | Example |
|----------|----------|---------|
| 1 | Docker Hub official | `postgres:15`, `redis:alpine` |
| 2 | GHCR | `ghcr.io/paperless-ngx/paperless-ngx:latest` |
| 3 | Local build | `docker build -t name-local .` |

If a Docker Hub image gives `denied` errors (rate limit or org restriction), try GHCR first. If GHCR also denies, build locally from `alpine:latest` + GitHub release binary.

### Local Image Builds (Fallback)
When no registry image is available, build from `alpine:latest`:

```bash
cat > "$SERVICE_DIR/Dockerfile" <<'DOCKERFILE'
FROM alpine:latest
RUN apk add --no-cache wget tar && \
    wget -qO /tmp/app.tar.gz "https://github.com/org/repo/releases/latest/download/linux-amd64-app.tar.gz" && \
    tar -xzf /tmp/app.tar.gz -C /usr/local/bin app && \
    rm /tmp/app.tar.gz
# Initialize any required state during build (not at runtime)
RUN app init --database /tmp/app.db && app users add admin admin --admin
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
DOCKERFILE

docker build --no-cache -t service-local "$SERVICE_DIR" || error "Docker build failed."
```

**Key rule for local builds:** Initialize databases and users **during `docker build`** (RUN steps), not in the entrypoint at runtime. Bake a template database into the image, then copy it on first start if the volume is empty.

```bash
# Good — happens at build time, guaranteed to work
RUN app db init && app users add admin admin --admin

# Risky — happens at runtime, can fail silently
ENTRYPOINT ["sh", "-c", "app db init && app start"]
```

### Health Check Pattern

**HTTP service:**
```bash
section "Step 10: Health Check"
info "Waiting for [Service] to be ready on port PORT..."
HEALTH_OK=0
for i in $(seq 1 12); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:PORT 2>/dev/null || echo "000")
    if echo "$STATUS" | grep -qE '^(200|301|302|303)$'; then
        info "Port PORT is responding (HTTP $STATUS) — [Service] is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/12 — waiting 5s..."
    sleep 5
    echo " retrying"
done
if [ "$HEALTH_OK" -eq 0 ]; then
    if nc -z 127.0.0.1 PORT 2>/dev/null; then
        warn "Port PORT is open but HTTP did not respond. Service may still be starting."
        warn "Check logs: docker logs CONTAINER"
    else
        warn "Port PORT is NOT responding after 60s."
        docker logs --tail 20 CONTAINER 2>&1 || true
    fi
fi
```

**HTTPS service (self-signed):** Use `curl -sf -k https://...`

**TCP-only service (no HTTP):** Use `nc -z 127.0.0.1 PORT`

**Slow-starting services** (Graylog, Plausible, Authentik): Use `seq 1 24` (24 × 5s = 120s) instead of `seq 1 12`.

**Services that redirect to /login:** Check for `200|301|302|303` using the `%{http_code}` pattern above — `curl -sf` alone fails silently on redirects.

### Server IP Detection
Always use this exact line — it filters to IPv4 only:
```bash
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
```

### Multi-Container Networks
Each service gets its own isolated bridge network:
```yaml
networks:
  service-net:
    driver: bridge
```

Add `networks: [service-net]` to every container in that stack.

---

## README.md Template

```markdown
# [Service] — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Service](URL) — one-line description.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

​```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/category/service/service-ubuntu.sh
chmod +x service-ubuntu.sh
sudo bash service-ubuntu.sh
​```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `PORT` | Web UI |

## 💻 Connect

​```bash
http://SERVER_IP:PORT
​```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
```

---

## Port Reference

Ports already in use across existing scripts — avoid these when adding new services:

| Port | Service |
|------|---------|
| `80` | Mailu, Mailcow (HTTP) |
| `443` | Pritunl, Mailcow (HTTPS) |
| `943` | OpenVPN AS |
| `2053` | 3X-UI panel |
| `2222` | Gitea SSH |
| `2283` | Immich |
| `2456–2458` | (reserved) |
| `3000` | AdGuard Home, Grafana |
| `3001` | Uptime Kuma |
| `3002` | Umami |
| `3100` | Gitea Web |
| `4533` | Navidrome |
| `5000` | Kavita |
| `5080` | Harbor |
| `5140` | Graylog Syslog |
| `5555` | SoftEther |
| `8000` | Woodpecker server |
| `8010` | Paperless-NGX |
| `8065` | Mattermost |
| `8082` | FileBrowser |
| `8084` | Pi-hole |
| `8085` | Guacamole |
| `8086` | Vaultwarden / InfluxDB |
| `8087` | Stirling PDF |
| `8088` | IT-Tools |
| `8089` | NetBird |
| `8090` | Beszel / Headscale |
| `8093` | Woodpecker CI |
| `8095` | ntfy |
| `8100` | Plausible |
| `8200` | Duplicati |
| `9000` | Graylog UI |
| `9001` | MinIO Console |
| `9003` | Woodpecker gRPC |
| `9010` | Authentik |
| `9090` | Prometheus |
| `9091` | Authelia |
| `9443` | Portainer / Authentik HTTPS |
| `12201` | Graylog GELF UDP |
| `13378` | Audiobookshelf |
| `19999` | Netdata |
| `21117` | RustDesk relay |
| `51821` | WireGuard Easy UI |

---

## Common Mistakes

- **Empty `touch` before volume mount** — Never pre-create a database file with `touch`. Either let the app create it fresh, or bake a pre-initialized template into the Docker image.
- **Firewall after health check** — Always open the UFW port in Step 8, before verify (Step 9) and health check (Step 10).
- **`curl -sf` on redirect endpoints** — FileBrowser, Gitea, and others return 302. Use `%{http_code}` and check for 200–303 instead of relying on `curl -sf` exit code alone.
- **`docker build` cache** — When changing a Dockerfile, always use `--no-cache` to force a clean rebuild.
- **Volume as file vs directory** — If an app expects a file (e.g. `app.db`), mount a file. If you mount a directory path where a file is expected, Docker creates a directory and the app fails.
