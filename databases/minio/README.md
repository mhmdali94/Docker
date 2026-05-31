# MinIO — Self-Hosted Docker Installer

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

High-performance, S3-compatible object storage for self-hosted file and media management.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## What is MinIO?

MinIO is an open-source, high-performance object storage system that is fully compatible with the Amazon S3 API. It is used to store unstructured data such as photos, videos, backups, and container images. Any S3-compatible client, SDK, or tool (AWS CLI, boto3, s3cmd) works with MinIO without modification.

---

## Quick Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/minio/minio-ubuntu.sh
chmod +x minio-ubuntu.sh
sudo bash minio-ubuntu.sh
```

The script automatically:
- Verifies Ubuntu 22.04 / 24.04
- Installs Docker & Docker Compose V2 if missing
- Generates secure credentials
- Starts the service stack
- Runs a health check

---

## Access

| | |
|---|---|
| **Web Console** | `http://SERVER_IP:9001` |
| **S3 API** | `http://SERVER_IP:9000` |
| **Username** | `minioadmin` |
| **Password** | Auto-generated (shown at install) |

> Replace `SERVER_IP` with your server's IP address.

---

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `9000` | TCP | S3 API |
| `9001` | TCP | Web Console |

---

## Data Location

| Path | Description |
|------|-------------|
| `/root/docker/minio/` | All service data and configuration |
| `/root/docker/minio/data/` | Object storage data |

---

## Management

```bash
# Follow logs
docker logs -f minio

# Stop the service
cd /root/docker/minio && docker compose down

# Start the service
cd /root/docker/minio && docker compose up -d

# Update to latest image
cd /root/docker/minio && docker compose pull && docker compose up -d
```

---

## Requirements

- Ubuntu 22.04 or 24.04
- Root or sudo access
- Ports open in firewall: 9000/tcp, 9001/tcp

---

> 💼 Need a production-ready setup? Contact **Mohammed Ali Elshikh** — [prismatechwork.com](https://prismatechwork.com)
