# Ollama + Open WebUI — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Ollama](https://ollama.com/) + [Open WebUI](https://github.com/open-webui/open-webui) — run local LLMs (Llama, Mistral, Gemma, Phi) with a ChatGPT-like web interface, entirely on your own server.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/ollama/ollama-ubuntu.sh
chmod +x ollama-ubuntu.sh
sudo bash ollama-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create your admin account on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `11434` | Ollama API |
| `3210` | Open WebUI |

## 💻 Connect

```bash
# Open WebUI (chat interface)
http://SERVER_IP:3210

# Ollama API
http://SERVER_IP:11434

# Pull a model after install
docker exec ollama ollama pull llama3.2

# List available models
docker exec ollama ollama list
```

## 📦 Pulling Models

After the installer finishes, pull your first model:

```bash
docker exec ollama ollama pull llama3.2        # ~2GB — fast, great quality
docker exec ollama ollama pull mistral         # ~4GB — strong reasoning
docker exec ollama ollama pull gemma2:2b       # ~1.6GB — lightweight
docker exec ollama ollama pull phi3            # ~2.3GB — Microsoft's small model
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
