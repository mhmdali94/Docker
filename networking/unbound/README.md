# Unbound — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Unbound](https://nlnetlabs.nl/projects/unbound/about/) — a validating, recursive DNS resolver — the perfect upstream for Pi-hole or AdGuard Home.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/unbound/unbound-ubuntu.sh
chmod +x unbound-ubuntu.sh
sudo bash unbound-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5335` | DNS TCP/UDP |

## 💻 Connect

```bash
dig @SERVER_IP -p 5335 example.com
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
