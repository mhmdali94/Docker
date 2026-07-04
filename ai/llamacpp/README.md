# llama.cpp Server — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [llama.cpp Server](https://github.com/ggml-org/llama.cpp) — the lightest way to self-host LLMs — OpenAI-compatible server (CPU by default).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/llamacpp/llamacpp-ubuntu.sh
chmod +x llamacpp-ubuntu.sh
sudo bash llamacpp-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8283` | HTTP API + web UI |

## 💻 Connect

```bash
curl http://SERVER_IP:8283/v1/models
```

## 📝 Notes

- Download any GGUF model (e.g. from Hugging Face) to `models/model.gguf` and restart the container.
- For GPU use the `:server-cuda` image tag and add the NVIDIA runtime.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
