# RustDesk Server Auto-Installer for Ubuntu

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

This script (`rustdesk-ubuntu.sh`) provides a fully automated way to install and configure a [RustDesk Self-Hosted Server](https://rustdesk.com/docs/en/self-host/) using Docker Compose.

**Made by:** [prismatechwork.com](https://prismatechwork.com)

---

## 🚀 What It Does

1. **OS Check** — Verifies Ubuntu 22.04 or 24.04
2. **Docker Check** — Installs Docker if missing
3. **Docker Compose V2 Check** — Installs the latest Compose V2 if needed
4. **Auto-detects WAN IP** — Pre-fills your VPS public IP as the default
5. **Full Cleanup** — Removes any existing `hbbs` / `hbbr` containers (including ghost containers with hash prefixes), prunes stale networks, and wipes the old directory
6. **Generates `docker-compose.yml`** — Injected with your custom domain or IP
7. **Starts Containers** — Auto-runs `docker compose up -d`
8. **Verifies Startup** — Confirms containers started successfully

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| **OS** | Ubuntu 22.04 or 24.04 |
| **Permissions** | Must be run as root (`sudo`) |
| **Network** | Ports 21115–21119 must be open in firewall/security groups |

---

## 🛠 Usage

**1. Make the script executable**
```bash
chmod +x rustdesk-ubuntu.sh
```

**2. Run as root**
```bash
sudo bash rustdesk-ubuntu.sh
```

**3. Follow the prompt**
Press **Enter** to accept the auto-detected WAN IP, or type a custom domain/IP:
```
Enter your domain or IP address [203.0.113.10]:
```

**4. Done!**
The script installs, cleans, configures, and starts everything automatically.

---

## 🌐 Ports Used

| Port | Protocol | Purpose |
|---|---|---|
| `21115` | TCP | NAT type test |
| `21116` | TCP + UDP | ID service & hole punching |
| `21117` | TCP | Relay service (`hbbr`) |
| `21118` | TCP | Web client support |
| `21119` | TCP | Relay web client support |

---

## 📁 Files Location

All configuration files are stored at:
```
/root/docker/rustdesk/docker-compose.yml
```

---

## ⚠️ Disclaimer

This script is provided **strictly for demo and testing purposes**.
It is **not hardened for production environments**.

---

**Made by [prismatechwork.com](https://prismatechwork.com)**