# MinIO — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [MinIO](https://min.io/) — high-performance, S3-compatible object storage.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/minio/minio-ubuntu.sh
chmod +x minio-ubuntu.sh
sudo bash minio-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Access Key (user) | Auto-generated (shown at install) |
| Secret Key (password) | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9000` | S3 API |
| `9001` | Web Console |

## 💻 Connect

```bash
# Web Console
http://SERVER_IP:9001

# S3 API endpoint
http://SERVER_IP:9000

# AWS CLI
aws --endpoint-url http://SERVER_IP:9000 s3 ls
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
