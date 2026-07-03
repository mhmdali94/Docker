# Borgmatic — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Borgmatic](https://torsion.org/borgmatic/) — simple, configuration-driven backups powered by BorgBackup (dedup + encryption).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/borgmatic/borgmatic-ubuntu.sh
chmod +x borgmatic-ubuntu.sh
sudo bash borgmatic-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Passphrase | Auto-generated (shown at install — save it!) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `—` | None |

## 💻 Connect

```bash
docker exec borgmatic borgmatic init --encryption repokey && docker exec borgmatic borgmatic
```

## 📝 Notes

- Mount the host directories you actually want backed up into `/mnt/source` in docker-compose.yml.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
