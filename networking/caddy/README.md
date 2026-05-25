# Caddy

Modern web server and reverse proxy with automatic HTTPS. Zero-config TLS via Let's Encrypt, simple config syntax, and hot reload — no restart needed after changes.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/caddy/caddy-ubuntu.sh
chmod +x caddy-ubuntu.sh
sudo bash caddy-ubuntu.sh
```

## What It Installs

- **Caddy 2** — Web server, reverse proxy, and TLS termination

## Ports

| Port | Service |
| --- | --- |
| 80 | HTTP |
| 443 | HTTPS (auto TLS) |
| 2019 | Admin API |

## Configuration

Edit `/root/docker/caddy/config/Caddyfile` — Caddy hot-reloads on save:

### Reverse proxy with auto HTTPS
```
yourdomain.com {
    reverse_proxy localhost:3000
}
```

### Multiple services
```
grafana.yourdomain.com {
    reverse_proxy localhost:3000
}

portainer.yourdomain.com {
    reverse_proxy localhost:9443
}
```

### Basic auth on a service
```
admin.yourdomain.com {
    basicauth {
        admin $2a$14$hashed_password_here
    }
    reverse_proxy localhost:8080
}
```

### Force reload after editing
```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Auto HTTPS

Point your domain's DNS A record at this server's IP. Caddy automatically:
1. Obtains a Let's Encrypt certificate
2. Renews it before expiry
3. Redirects HTTP → HTTPS

No ports 80/443 must be in use by other services.

## Notes

- TLS certificates stored in `./data/`
- Static site files go in `./site/`
- Runs with `network_mode: host` for direct access to all local services
