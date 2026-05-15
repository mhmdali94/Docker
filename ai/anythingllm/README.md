# AnythingLLM — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [AnythingLLM](https://anythingllm.com/) — the full-stack AI application that lets you chat with your documents using RAG (Retrieval-Augmented Generation). Connects to Ollama, OpenAI, Anthropic, or any LLM provider.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/anythingllm/anythingllm-ubuntu.sh
chmod +x anythingllm-ubuntu.sh
sudo bash anythingllm-ubuntu.sh
```

## 🔑 Credentials

No default credentials — create your admin account on first visit.

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3030` | AnythingLLM Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:3030
```

## 💡 Connecting to Ollama

If you have Ollama running on the same server, set the LLM provider to:
- **Provider:** Ollama
- **Base URL:** `http://SERVER_IP:11434`

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
