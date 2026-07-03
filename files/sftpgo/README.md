# SFTPGo — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [SFTPGo](https://sftpgo.com) — a full-featured SFTP/FTP/WebDAV server with web admin and user management.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/files/sftpgo/sftpgo-ubuntu.sh
chmod +x sftpgo-ubuntu.sh
sudo bash sftpgo-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8154` | Web admin/client |
| `2022` | SFTP |

## 💻 Connect

```bash
sftp -P 2022 user@SERVER_IP
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
