# AI Stack — One-Command Stack

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

A private ChatGPT with live web search: **Ollama + Open WebUI + SearXNG + LiteLLM**. A starter model is pulled automatically — chat immediately after install.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/stacks/ai-stack/ai-stack-ubuntu.sh
chmod +x ai-stack-ubuntu.sh
sudo bash ai-stack-ubuntu.sh
```

## 📦 What's inside

- **Ollama** — local LLM runtime (starter model auto-pulled)
- **Open WebUI** — the chat interface, web search pre-enabled
- **SearXNG** — private meta-search feeding the chat
- **LiteLLM** — OpenAI-compatible API endpoint for your apps

## 🌐 Ports

| Port | Service |
|------|---------|
| `3210` | Open WebUI |
| `11434` | Ollama API |
| `8081` | SearXNG |
| `4001` | LiteLLM (OpenAI-compatible) |

## 🔗 Wiring

Fully wired: WebUI → Ollama, WebUI search → SearXNG (JSON enabled), LiteLLM → Ollama. `qwen2.5:0.5b` is pulled at install; add bigger models with `docker exec ai-ollama ollama pull llama3.2`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
