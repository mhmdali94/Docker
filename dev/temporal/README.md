# Temporal — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Temporal](https://temporal.io) — the durable-execution workflow engine used by Netflix, Stripe and co.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/temporal/temporal-ubuntu.sh
chmod +x temporal-ubuntu.sh
sudo bash temporal-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `7233` | gRPC frontend |
| `8242` | Web UI |

## 💻 Connect

```bash
temporal workflow list --address SERVER_IP:7233
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
