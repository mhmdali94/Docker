# Traefik — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Traefik](https://traefik.io/traefik/) — cloud-native reverse proxy and load balancer. Automatic HTTPS with Let's Encrypt, Docker-native service discovery, and a built-in dashboard. A modern alternative to Nginx Proxy Manager.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/traefik/traefik-ubuntu.sh
chmod +x traefik-ubuntu.sh
sudo bash traefik-ubuntu.sh
```

## 🔑 Credentials

No credentials — dashboard is open by default on port 8080.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `80` | HTTP entrypoint |
| `443` | HTTPS entrypoint |
| `8080` | Traefik Dashboard |

## 💻 Connect

```bash
# Traefik Dashboard
http://SERVER_IP:8080/dashboard/#/
```

## 💡 Exposing Other Services via Traefik

Add these labels to any Docker service to route traffic through Traefik:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.example.com`)"
  - "traefik.http.services.myapp.loadbalancer.server.port=3000"
```

## ⚠️ Security Note

The dashboard has no authentication in this demo setup. In production, add BasicAuth middleware or restrict access to trusted IPs.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
