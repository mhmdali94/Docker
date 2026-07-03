# Atuin Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Atuin Server](https://atuin.sh) — sync, search and back up your shell history across machines.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/atuin/atuin-ubuntu.sh
chmod +x atuin-ubuntu.sh
sudo bash atuin-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8888` | Sync API |

## 💻 Connect

```bash
atuin register --host http://SERVER_IP:8888
```

## 📝 Notes

- Disable ATUIN_OPEN_REGISTRATION after creating your accounts.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
