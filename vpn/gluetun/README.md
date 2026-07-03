# Gluetun — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Gluetun](https://github.com/qdm12/gluetun) — a VPN client container — route qBittorrent or any container through NordVPN, Mullvad, ProtonVPN and 20+ providers.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/vpn/gluetun/gluetun-ubuntu.sh
chmod +x gluetun-ubuntu.sh
sudo bash gluetun-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8223` | Control server |

## 💻 Connect

```bash
Add network_mode: "container:gluetun" to another service
```

## 📝 Notes

- For WireGuard-based providers switch VPN_TYPE and add the WIREGUARD_* env vars — see Gluetun wiki.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
