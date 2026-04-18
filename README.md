# 🐳 Docker Self-Hosted Services Collection

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Services](https://img.shields.io/badge/Services-51-brightgreen)
![Categories](https://img.shields.io/badge/Categories-15-purple)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2022.04%20%7C%2024.04-orange)

A collection of one-command Docker installer scripts for self-hosted services, organized by category.

Each service directory contains:

- a `README.md` with usage, ports, credentials, and access notes
- a `*-ubuntu.sh` installer script for Ubuntu `22.04` and `24.04`

**Made by:** Mohammed Ali Elshikh - [prismatechwork.com](https://prismatechwork.com)

> ⚠️ Scripts in this repository are provided for **demo and testing purposes only** and are not intended for production use.

---

## 📌 At A Glance

- 51 services across 15 categories
- Ubuntu-focused installers with Docker and Docker Compose V2 checks built in
- Per-service deployments are typically created under `/root/docker/<service>`
- Most scripts generate credentials, start the stack, and run a basic health check
- Re-running a script often removes the previous deployment for a clean reinstall

---

## 📂 Categories

| Category | Count | Services |
| --- | ---: | --- |
| Analytics | 2 | [Plausible](./analytics/plausible/), [Umami](./analytics/umami/) |
| Backup | 1 | [Duplicati](./backup/duplicati/) |
| Communication | 2 | [Mattermost](./communication/mattermost/), [ntfy](./communication/ntfy/) |
| Databases | 6 | [InfluxDB](./databases/influxdb/), [MariaDB](./databases/mariadb/), [MinIO](./databases/minio/), [MongoDB](./databases/mongodb/), [PostgreSQL](./databases/postgres/), [Redis](./databases/redis/) |
| Dev | 3 | [Gitea](./dev/gitea/), [Harbor](./dev/harbor/), [Woodpecker](./dev/woodpecker/) |
| Email | 3 | [Listmonk](./email/listmonk/), [Mailcow](./email/mailcow/), [Mailu](./email/mailu/) |
| Files | 3 | [FileBrowser](./files/filebrowser/), [Nextcloud](./files/nextcloud/), [Paperless-ngx](./files/paperless-ngx/) |
| Management | 1 | [Portainer](./management/portainer/) |
| Media | 5 | [Audiobookshelf](./media/audiobookshelf/), [Immich](./media/immich/), [Jellyfin](./media/jellyfin/), [Kavita](./media/kavita/), [Navidrome](./media/navidrome/) |
| Monitoring | 6 | [Beszel](./monitoring/beszel/), [Grafana](./monitoring/grafana/), [Graylog](./monitoring/graylog/), [Netdata](./monitoring/netdata/), [Prometheus](./monitoring/prometheus/), [Uptime Kuma](./monitoring/uptime-kuma/) |
| Networking | 3 | [AdGuard Home](./networking/adguardhome/), [Nginx Proxy Manager](./networking/npm/), [Pi-hole](./networking/pihole/) |
| Remote Access | 3 | [Guacamole](./remote-access/guacamole/), [Remotely](./remote-access/remotely/), [RustDesk](./remote-access/rustdesk/) |
| Security | 3 | [Authentik](./security/authentik/), [Authelia](./security/authelia/), [Vaultwarden](./security/vaultwarden/) |
| Tools | 2 | [IT-Tools](./tools/it-tools/), [Stirling-PDF](./tools/stirling-pdf/) |
| VPN | 8 | [3X-UI](./vpn/3x-ui/), [Headscale](./vpn/headscale/), [NetBird](./vpn/netbird/), [OpenVPN AS](./vpn/openvpn-as/), [Outline](./vpn/outline/), [Pritunl](./vpn/pritunl/), [SoftEther](./vpn/softether/), [WireGuard Easy](./vpn/wireguard-easy/) |

---

## 🛠 Usage

Pick a service folder, then run its installer script.

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/<category>/<service>/<service>-ubuntu.sh
chmod +x <service>-ubuntu.sh
sudo bash <service>-ubuntu.sh
```

Examples:

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/jellyfin/jellyfin-ubuntu.sh
chmod +x jellyfin-ubuntu.sh
sudo bash jellyfin-ubuntu.sh
```

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/vaultwarden/vaultwarden-ubuntu.sh
chmod +x vaultwarden-ubuntu.sh
sudo bash vaultwarden-ubuntu.sh
```

For exact ports, credentials, and post-install steps, use the `README.md` inside the selected service folder.

---

## 📋 Requirements

- Ubuntu `22.04` or `24.04`
- Root or sudo access
- Internet access for package installs and Docker image pulls
- Open firewall ports as required by the selected service

---

## 🧱 Repository Structure

```text
.
|- analytics/
|- backup/
|- communication/
|- databases/
|- dev/
|- email/
|- files/
|- gpt.md
|- management/
|- media/
|- monitoring/
|- networking/
|- remote-access/
|- security/
|- tools/
|- vpn/
|- CONTRIBUTING.md
|- LICENSE
`- README.md
```

Per-service layout:

```text
category/service-name/
|- README.md
`- service-name-ubuntu.sh
```

---

## ⚙️ Common Script Behavior

Most scripts follow the same high-level flow:

1. check for root privileges
2. verify supported Ubuntu version
3. install or verify Docker
4. install or verify Docker Compose V2
5. clean up old containers and previous service data
6. prepare `/root/docker/<service>`
7. generate credentials and write configuration
8. start the stack with Docker Compose
9. verify the container is running
10. perform a basic health check

---

## ⚠️ Important Notes

- These setups are intended for demos, testing, and lab use.
- Some scripts expose default or generated credentials during installation.
- Some services require additional manual configuration after install, such as DNS, SMTP, OAuth, or client-side setup.
- Some installers use broad host mounts, Docker socket access, host networking, or elevated capabilities where the service requires it.
- If you need production-grade deployments, treat these scripts as starting points rather than final hardened setups.

---

## 🤝 Contributing

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the script structure, naming conventions, cleanup rules, health check patterns, and port allocation guidance used in this repository.

---

**Made by Mohammed Ali Elshikh - [prismatechwork.com](https://prismatechwork.com)**
