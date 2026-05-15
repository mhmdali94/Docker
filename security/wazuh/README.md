# Wazuh — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Wazuh](https://wazuh.com/) — open-source SIEM and XDR platform. Threat detection, log analysis, vulnerability management, file integrity monitoring, and compliance reporting in one platform.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/wazuh/wazuh-ubuntu.sh
chmod +x wazuh-ubuntu.sh
sudo bash wazuh-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8443` | Wazuh Dashboard (HTTPS) |
| `1514` | Agent log collection (UDP) |
| `1515` | Agent enrollment (TCP) |
| `55000` | Wazuh API (TCP) |
| `9200` | Wazuh Indexer (TCP) |

## 💻 Connect

```bash
# Dashboard (accepts self-signed certificate)
https://SERVER_IP:8443

# Install agent on another Ubuntu server
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
# Then configure WAZUH_MANAGER=SERVER_IP during agent install
```

## ⚙️ Notes

- Dashboard uses a self-signed SSL certificate — accept the browser warning
- Wazuh takes ~3-5 minutes to fully initialize on first boot

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
