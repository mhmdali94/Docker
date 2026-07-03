# SeaweedFS — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [SeaweedFS](https://seaweedfs.github.io) — a fast distributed storage system with S3 API — lightweight MinIO alternative.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/seaweedfs/seaweedfs-ubuntu.sh
chmod +x seaweedfs-ubuntu.sh
sudo bash seaweedfs-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8333` | S3 API |
| `9334` | Master UI |

## 💻 Connect

```bash
aws --endpoint-url http://SERVER_IP:8333 s3 ls
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
