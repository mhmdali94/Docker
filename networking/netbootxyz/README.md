# netboot.xyz — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [netboot.xyz](https://netboot.xyz) — network-boot any OS installer or utility over PXE — no more USB sticks.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/netbootxyz/netbootxyz-ubuntu.sh
chmod +x netbootxyz-ubuntu.sh
sudo bash netbootxyz-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3064` | Web UI |
| `69/udp` | TFTP |
| `8322` | Asset server |

## 💻 Connect

```bash
http://SERVER_IP:3064
```

## 📝 Notes

- Set DHCP option 66 (next-server) to this host and option 67 to `netboot.xyz.kpxe` (BIOS) or `netboot.xyz.efi` (UEFI).

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
