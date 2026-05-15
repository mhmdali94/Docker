# Technitium DNS Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Technitium DNS Server](https://technitium.com/dns/) — self-hosted authoritative and recursive DNS server. Built-in ad-blocking, split-horizon DNS, DNS-over-HTTPS (DoH), DNS-over-TLS (DoT), and a clean web management UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/technitium/technitium-ubuntu.sh
chmod +x technitium-ubuntu.sh
sudo bash technitium-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `53` | DNS (UDP + TCP) |
| `5380` | Web Management UI |

## 💻 Connect

```bash
# Web Management UI
http://SERVER_IP:5380

# Test DNS resolution
dig @SERVER_IP google.com

# Point your devices to this DNS server: SERVER_IP
```

## ⚙️ Notes

- If port 53 conflicts with `systemd-resolved`, run: `systemctl disable --now systemd-resolved`
- Supports blocklists for ad-blocking — add them under **Settings → Blocking**
- Supports DoH at: `https://SERVER_IP/dns-query`

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
