# CrowdSec — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [CrowdSec](https://www.crowdsec.net/) — open-source crowd-sourced IPS. Analyzes logs to detect attacks and contributes threat intelligence to a global security community. Block IPs that are attacking others — before they attack you.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/crowdsec/crowdsec-ubuntu.sh
chmod +x crowdsec-ubuntu.sh
sudo bash crowdsec-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Local API Key | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `6060` | Prometheus metrics |
| `8181` | Local API |

## 💻 Connect

```bash
# Check CrowdSec status
docker exec crowdsec cscli metrics

# View active decisions (blocked IPs)
docker exec crowdsec cscli decisions list

# View alerts
docker exec crowdsec cscli alerts list

# Add a bouncer (e.g. firewall)
docker exec crowdsec cscli bouncers add my-firewall-bouncer
```

## 💡 Bouncers

CrowdSec itself only detects threats — install a **bouncer** to actively block them:
- `cs-firewall-bouncer` — blocks at iptables/nftables level
- `cs-nginx-bouncer` — blocks at Nginx level
- `cs-cloudflare-bouncer` — integrates with Cloudflare

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
