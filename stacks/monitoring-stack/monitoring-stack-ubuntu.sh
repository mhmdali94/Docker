#!/bin/bash
# ============================================================
#   Monitoring Stack Auto-Installer (Prometheus + Grafana)
#   node-exporter + cAdvisor, datasource & dashboard provisioned
#   Made by: Mohammed Ali Elshikh | prismatechwork.com
#   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️
# ============================================================
set -e

info()    { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()    { echo -e "\e[33m[WARN]\e[0m $*"; }
error()   { echo -e "\e[31m[ERROR]\e[0m $*"; exit 1; }
section() { echo -e "\n\e[36m========== $* ==========\e[0m"; }

clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   MONITORING STACK Auto-Installer"
echo "  ║   Prometheus + Grafana + node-exporter + cAdvisor"
echo "  ║   Datasource and host dashboard pre-provisioned"
echo "  ║"
echo "  ║   Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║   ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Press ENTER to continue... Ctrl+C to cancel."
read -rp "" _DEMO_CONFIRM

section "Step 0: Checking Privileges"
if [ "$EUID" -ne 0 ]; then error "Please run as root: sudo bash $0"; fi
info "Running as root. OK."

section "Step 1: Verifying OS"
[ -f /etc/os-release ] || error "Cannot determine OS."
. /etc/os-release
[ "$ID" = "ubuntu" ] || error "Only Ubuntu is supported. Found: $ID"
{ [ "$VERSION_ID" = "22.04" ] || [ "$VERSION_ID" = "24.04" ]; } || error "Only Ubuntu 22.04/24.04 supported. Found: $VERSION_ID"
info "OS check passed: Ubuntu $VERSION_ID"

section "Step 2: Checking Docker"
if ! command -v docker &> /dev/null; then
    warn "Docker not found. Installing..."
    apt update -y && apt install -y docker.io
    systemctl enable --now docker
else
    info "Docker: $(docker --version)"
fi

section "Step 3: Checking Docker Compose V2"
if ! docker compose version &> /dev/null; then
    warn "Docker Compose V2 not found. Installing..."
    apt update -y && apt install -y docker-compose-v2 || apt install -y docker-compose
fi
info "Docker Compose: $(docker compose version)"

section "Step 4: Cleaning Up Existing Containers & Data"
SERVICE_DIR="/root/docker/monitoring-stack"
EXISTING=$(docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^mon-(prometheus|grafana|node-exporter|cadvisor)$' || true)
if [ -n "$EXISTING" ]; then
    warn "Stopping and removing existing stack containers..."
    echo "$EXISTING" | xargs docker rm -f 2>/dev/null || true
fi
if [ -d "$SERVICE_DIR" ]; then
    warn "Removing existing configuration at $SERVICE_DIR..."
    rm -rf "$SERVICE_DIR"
fi
docker network prune -f &>/dev/null || true
info "Cleanup complete."

section "Step 5: Preparing Directories"
mkdir -p "$SERVICE_DIR"/{prometheus-data,grafana-data,provisioning/datasources,provisioning/dashboards,dashboards}
chown -R 65534:65534 "$SERVICE_DIR/prometheus-data"
chown -R 472:472 "$SERVICE_DIR/grafana-data"
cd "$SERVICE_DIR" || error "Cannot navigate to $SERVICE_DIR"
info "Directory ready: $SERVICE_DIR"

section "Step 6: Generating Configuration"
SERVER_IP=$(hostname -I | tr ' ' '\n' | grep -E '^[0-9]+\.' | head -1)
GRAFANA_PASS=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
info "Grafana login: admin / $GRAFANA_PASS"

cat > "$SERVICE_DIR/prometheus.yml" <<'CONFIG'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]
  - job_name: node
    static_configs:
      - targets: ["mon-node-exporter:9100"]
  - job_name: cadvisor
    static_configs:
      - targets: ["mon-cadvisor:8080"]
CONFIG

cat > "$SERVICE_DIR/provisioning/datasources/prometheus.yml" <<'CONFIG'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://mon-prometheus:9090
    isDefault: true
CONFIG

cat > "$SERVICE_DIR/provisioning/dashboards/provider.yml" <<'CONFIG'
apiVersion: 1
providers:
  - name: default
    folder: ""
    type: file
    options:
      path: /var/lib/grafana/dashboards
CONFIG

cat > "$SERVICE_DIR/dashboards/host-overview.json" <<'CONFIG'
{
  "title": "Host Overview",
  "uid": "host-overview",
  "timezone": "browser",
  "refresh": "30s",
  "time": { "from": "now-1h", "to": "now" },
  "panels": [
    {
      "title": "CPU Usage %",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
      "targets": [{ "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)", "legendFormat": "cpu" }]
    },
    {
      "title": "Memory Used %",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 },
      "targets": [{ "expr": "(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100", "legendFormat": "memory" }]
    },
    {
      "title": "Disk Used % (/)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 8 },
      "targets": [{ "expr": "100 - (node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"} * 100)", "legendFormat": "/" }]
    },
    {
      "title": "Network RX/TX (bytes/s)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 8 },
      "targets": [
        { "expr": "sum(rate(node_network_receive_bytes_total[5m]))", "legendFormat": "rx" },
        { "expr": "sum(rate(node_network_transmit_bytes_total[5m]))", "legendFormat": "tx" }
      ]
    }
  ],
  "schemaVersion": 39
}
CONFIG
info "Prometheus config, Grafana datasource + dashboard provisioned."

cat > "$SERVICE_DIR/docker-compose.yml" <<EOF
services:
  mon-prometheus:
    image: prom/prometheus:latest
    container_name: mon-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus-data:/prometheus
    networks: [mon-net]

  mon-node-exporter:
    image: prom/node-exporter:latest
    container_name: mon-node-exporter
    restart: unless-stopped
    pid: host
    command:
      - --path.rootfs=/host
    volumes:
      - /:/host:ro,rslave
    networks: [mon-net]

  mon-cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: mon-cadvisor
    restart: unless-stopped
    privileged: true
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg
    networks: [mon-net]

  mon-grafana:
    image: grafana/grafana:latest
    container_name: mon-grafana
    restart: unless-stopped
    depends_on:
      - mon-prometheus
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: $GRAFANA_PASS
    volumes:
      - ./grafana-data:/var/lib/grafana
      - ./provisioning:/etc/grafana/provisioning:ro
      - ./dashboards:/var/lib/grafana/dashboards:ro
    networks: [mon-net]

networks:
  mon-net:
    driver: bridge
EOF
info "docker-compose.yml created."

section "Step 7: Starting the Monitoring Stack"
MAX_RETRIES=3
for attempt in $(seq 1 $MAX_RETRIES); do
    docker compose up -d && break
    warn "Docker pull failed on attempt $attempt/$MAX_RETRIES."
    [ "$attempt" -lt "$MAX_RETRIES" ] && info "Retrying in 15s..." && sleep 15
    [ "$attempt" -eq "$MAX_RETRIES" ] && error "Failed to start after $MAX_RETRIES attempts."
done

section "Step 8: Opening Firewall Ports"
if command -v ufw &> /dev/null; then
    ufw allow 3000/tcp
    ufw allow 9090/tcp
    info "UFW: ports 3000 and 9090 opened."
else
    warn "UFW not found — skipping firewall rules."
fi

section "Step 9: Verifying Containers"
sleep 10
RUNNING=$(docker ps --format '{{.Names}}' | grep -c '^mon-' || true)
info "Stack containers running: $RUNNING/4"

section "Step 10: Health Check"
HEALTH_OK=0
for i in $(seq 1 24); do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3000/api/health 2>/dev/null || echo "000")
    if [ "$STATUS" = "200" ]; then
        info "Grafana is healthy. ✅"
        HEALTH_OK=1
        break
    fi
    echo -n "  Attempt $i/24 — waiting 5s..."
    sleep 5
    echo " retrying"
done
[ "$HEALTH_OK" -eq 0 ] && warn "Grafana not responding yet. Check: docker logs mon-grafana"

echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║           ✅  MONITORING STACK READY!                ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  📊  Grafana:     http://$SERVER_IP:3000"
echo "  ║      Login: admin / $GRAFANA_PASS"
echo "  ║      → The 'Host Overview' dashboard is already there."
echo "  ║  📈  Prometheus:  http://$SERVER_IP:9090"
echo "  ║"
echo "  ║  Already wired: Prometheus scrapes the host (node-exporter)"
echo "  ║  and every container (cAdvisor); Grafana datasource is set."
echo "  ║  💡  Import dashboard IDs 1860 + 14282 for deep dives."
echo "  ║"
echo "  ║  ⚠️  FOR DEMO / TESTING PURPOSES ONLY ⚠️"
echo "  ║       Made by: Mohammed Ali Elshikh | prismatechwork.com"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🚀  Need production setup?                         ║"
echo "  ║      👨‍💻  Mohammed Ali Elshikh | prismatechwork.com"
echo "  ║  ☕  USDT (TRC-20): TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
