# Privacy Stack — One-Command Stack

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

**WireGuard → AdGuard Home → Unbound**: VPN clients automatically get ad-blocking, tracker-filtering, fully recursive DNS that depends on no third-party resolver.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/stacks/privacy-stack/privacy-stack-ubuntu.sh
chmod +x privacy-stack-ubuntu.sh
sudo bash privacy-stack-ubuntu.sh
```

## 📦 What's inside

- **WireGuard (wg-easy)** — VPN with a web UI
- **AdGuard Home** — DNS filtering (ads/trackers)
- **Unbound** — recursive resolver (no upstream provider)

## 🌐 Ports

| Port | Service |
|------|---------|
| `51820/udp` | WireGuard | 
| `51821` | WireGuard web UI |
| `53` | DNS |
| `3053` | AdGuard setup wizard |
| `8083` | AdGuard dashboard |

## 🔗 Wiring

Fixed container IPs (Unbound `10.8.10.2`, AdGuard `10.8.10.3`); WireGuard clients are pre-set to use AdGuard as DNS. One manual step: point AdGuard's upstream at Unbound in the setup wizard (printed at install).

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
