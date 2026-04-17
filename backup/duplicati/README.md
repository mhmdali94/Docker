# Duplicati — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Duplicati](https://www.duplicati.com/) — a free backup solution that stores encrypted, incremental, compressed backups to cloud storage or local targets.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/duplicati/duplicati-ubuntu.sh
chmod +x duplicati-ubuntu.sh
sudo bash duplicati-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| UI Password | Set in Settings after first launch |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8200` | Duplicati Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8200

# Source files (entire host, read-only)
/source/

# Default backup destination
/root/docker/duplicati/backups/

# Supported backends: S3, B2, SFTP, OneDrive, Google Drive, FTP, and more
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
