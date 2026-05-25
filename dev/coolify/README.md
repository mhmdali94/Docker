# Coolify

Self-hosted Heroku/Netlify/Vercel alternative. Deploy apps, databases, and services from Git with one click — on your own server.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/coolify/coolify-ubuntu.sh
chmod +x coolify-ubuntu.sh
sudo bash coolify-ubuntu.sh
```

## What It Installs

Coolify uses its own official installer which sets up all required components automatically.

## Ports

| Port | Service |
| --- | --- |
| 8000 | Coolify dashboard |
| 6001 | Coolify WebSocket |
| 6002 | Coolify terminal proxy |

## Access

| | URL |
| --- | --- |
| Coolify | `http://<server-ip>:8000` |

## Default Credentials

No default credentials — create your admin account on first visit.

## What You Can Deploy with Coolify

- **Applications** — Node.js, PHP, Python, Ruby, Go, static sites
- **Databases** — PostgreSQL, MySQL, MariaDB, MongoDB, Redis
- **Docker Compose** — Any compose file from a Git repo
- **One-click services** — WordPress, Ghost, Plausible, and 50+ more

## Notes

- Coolify requires Docker and manages its own containers
- Connect your Git provider (GitHub, GitLab, Bitbucket) for automatic deployments
- Supports Let's Encrypt SSL automatically
- Deploy to multiple servers from one Coolify instance
- Free and open source (no usage limits)
