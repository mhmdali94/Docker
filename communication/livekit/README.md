# LiveKit — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [LiveKit](https://livekit.io) — a high-performance WebRTC SFU for realtime audio/video (powers many AI voice apps).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/communication/livekit/livekit-ubuntu.sh
chmod +x livekit-ubuntu.sh
sudo bash livekit-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| API key | `devkey` |
| Secret | `secret` (dev mode only!) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `7880` | WebSocket/API |
| `7881` | RTC TCP |
| `7882/udp` | RTC UDP |

## 💻 Connect

```bash
wss://SERVER_IP:7880 (behind TLS proxy) or ws://SERVER_IP:7880
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
