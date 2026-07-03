# Taiga — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Taiga](https://taiga.io) — the agile project management platform (scrum + kanban).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/project-management/taiga/taiga-ubuntu.sh
chmod +x taiga-ubuntu.sh
sudo bash taiga-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Admin | Create with `docker exec -it taiga-back python manage.py createsuperuser` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9013` | Web UI (gateway) |

## 💻 Connect

```bash
http://SERVER_IP:9013
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
