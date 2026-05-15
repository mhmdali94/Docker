# n8n

Low-code workflow automation — connect apps, APIs, and services with a visual node-based editor (Zapier alternative).

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/n8n/n8n-ubuntu.sh
chmod +x n8n-ubuntu.sh
sudo bash n8n-ubuntu.sh
```

## What It Installs

- **n8n** — workflow automation engine
- **PostgreSQL** — persistent workflow storage

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:5678 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 5678 | n8n Web UI |

## Connect

Log in at `http://<server-ip>:5678`. Create workflows by connecting nodes from 400+ integrations. Workflows trigger on webhooks, schedules, or manual execution.
