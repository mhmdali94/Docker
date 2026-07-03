# Core Keeper Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Core Keeper Server](https://github.com/escapingnetwork/core-keeper-dedicated) — a dedicated server for the mining sandbox game Core Keeper (no open ports needed — uses relay Game ID).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/core-keeper/core-keeper-ubuntu.sh
chmod +x core-keeper-ubuntu.sh
sudo bash core-keeper-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Game ID | Shown in `docker logs core-keeper` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `—` | None (Steam relay via Game ID) |

## 💻 Connect

```bash
docker logs core-keeper 2>&1 | grep -i 'Game ID'
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
