# InvokeAI — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [InvokeAI](https://invoke-ai.github.io/InvokeAI/) — a polished Stable Diffusion creative studio with a professional UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/invokeai/invokeai-ubuntu.sh
chmod +x invokeai-ubuntu.sh
sudo bash invokeai-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9090` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:9090
```

## 📝 Notes

- For NVIDIA GPU acceleration add the `deploy.resources.reservations.devices` GPU block and the NVIDIA container runtime.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
