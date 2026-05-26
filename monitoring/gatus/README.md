# Gatus

Developer-oriented health monitoring and status page. Define endpoints in YAML, monitor uptime, response times, and SSL certs — and show a clean public status page.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/gatus/gatus-ubuntu.sh
chmod +x gatus-ubuntu.sh
sudo bash gatus-ubuntu.sh
```

## What It Installs

- **Gatus** — Health monitoring + status page

## Ports

| Port | Service |
| --- | --- |
| 8097 | Gatus status page + API |

## Access

| | URL |
| --- | --- |
| Status Page | `http://<server-ip>:8097` |

## Configuration

Edit `/root/docker/gatus/config/config.yaml` — Gatus hot-reloads on change:

```yaml
endpoints:
  - name: My App
    url: http://localhost:3000
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 500"

  - name: My API
    url: https://api.example.com/health
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[BODY] == {\"status\":\"ok\"}"
```

## Alerting

Add alerts to `config.yaml`:
```yaml
alerting:
  slack:
    webhook-url: https://hooks.slack.com/services/...
```

Supports Slack, PagerDuty, email, Telegram, Discord, and more.

## Notes

- History stored in SQLite at `./data/gatus.db`
- Supports HTTP, TCP, DNS, ICMP, and WebSocket checks
- Response time graphs and uptime percentages built-in
