# Scrutiny — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Scrutiny](https://github.com/AnalogJ/scrutiny) — hard drive S.M.A.R.T. monitoring with a modern dashboard.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/monitoring/scrutiny/scrutiny-ubuntu.sh
chmod +x scrutiny-ubuntu.sh
sudo bash scrutiny-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8135` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8135
```

## 📝 Notes

- The compose file maps `/dev/sda` by default — add every disk you want monitored under `devices:` and restart.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
