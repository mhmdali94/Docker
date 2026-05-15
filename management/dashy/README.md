# Dashy

Highly customizable self-hosted homepage and dashboard for all your self-hosted services.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/management/dashy/dashy-ubuntu.sh
chmod +x dashy-ubuntu.sh
sudo bash dashy-ubuntu.sh
```

## What It Installs

- **Dashy** — self-hosted dashboard

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:4000 |
| Auth | None (demo mode) |

## Ports

| Port | Service |
| --- | --- |
| 4000 | Dashy Web UI |

## Connect

Open `http://<server-ip>:4000`. Edit `./conf.yaml` on the host to add your services, set themes, and configure widgets. Changes take effect after a page reload (or container restart for YAML changes).
