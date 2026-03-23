# Apache Guacamole — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Apache Guacamole](https://guacamole.apache.org/) — a clientless remote desktop gateway that supports VNC, RDP, and SSH entirely through a web browser.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🚀 What the Script Does

1. **OS Check** — Verifies Ubuntu 22.04 or 24.04
2. **Docker Check** — Installs Docker if missing
3. **Docker Compose V2 Check** — Installs if missing
4. **Cleanup** — Removes any existing Guacamole containers and directory
5. **Generates `docker-compose.yml`** — Ready-to-run stack
6. **Starts Container** — `docker compose up -d`
7. **Shows login info** — Admin URL and credentials

---

## 🛠 Usage

```bash
chmod +x guacamole-ubuntu.sh
sudo bash guacamole-ubuntu.sh
```

---

## 🔑 Default Login Credentials

| Field | Value |
|-------|-------|
| **Username** | `guacadmin` |
| **Password** | `guacadmin` |

> ⚠️ Change these immediately after first login!

---

## 🌐 Ports Used

| Port | Purpose |
|------|---------|
| `8090` | Guacamole Web UI |

Access the panel at: `http://<your-server-ip>:8090/guacamole`

---

## 📁 Files Location

```
/root/docker/guacamole/
├── docker-compose.yml
└── postgres/     ← persistent config & data volume
```

---

## ⚠️ Disclaimer

This setup is provided **strictly for demo and testing purposes**.
It is **not hardened for production environments**.

---

**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
