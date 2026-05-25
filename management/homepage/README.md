# Homepage

A highly customizable self-hosted dashboard for all your services. Shows live stats, Docker container status, and integrates with 100+ services.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/homepage/homepage-ubuntu.sh
chmod +x homepage-ubuntu.sh
sudo bash homepage-ubuntu.sh
```

## What It Installs

- **Homepage** — Modern, fast self-hosted dashboard

## Ports

| Port | Service |
| --- | --- |
| 3333 | Homepage dashboard |

## Access

| | URL |
| --- | --- |
| Dashboard | `http://<server-ip>:3333` |

## Default Credentials

None — open access. Restrict with a reverse proxy if needed.

## Configuration

All config lives in `./config/` as YAML files:

| File | Purpose |
| --- | --- |
| `settings.yaml` | Theme, title, layout |
| `services.yaml` | Service tiles with links and icons |
| `bookmarks.yaml` | Quick-access bookmarks |
| `widgets.yaml` | Live stats widgets |

### Adding a Service

Edit `./config/services.yaml`:
```yaml
- Monitoring:
    - Grafana:
        href: http://server-ip:3000
        description: Metrics dashboard
        icon: grafana.png
    - Uptime Kuma:
        href: http://server-ip:3001
        description: Uptime monitoring
        icon: uptime-kuma.png
```

### Docker Integration

Homepage reads the Docker socket (`/var/run/docker.sock`) and can show live container status automatically. Add labels to containers:

```yaml
labels:
  homepage.group: Monitoring
  homepage.name: Grafana
  homepage.icon: grafana.png
  homepage.href: http://server-ip:3000
  homepage.description: Metrics dashboard
```

## Notes

- 6000+ service icons available automatically by name
- Supports 100+ service integrations (Sonarr, Radarr, Portainer, etc.) with live stats
- Hot-reloads config files — no restart needed after edits
- Dark and light themes supported
