# Perplexica — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Perplexica](https://github.com/ItzCrazyKns/Perplexica) — an open-source AI-powered answer engine (Perplexity alternative). Pairs with the SearXNG and Ollama scripts.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/perplexica/perplexica-ubuntu.sh
chmod +x perplexica-ubuntu.sh
sudo bash perplexica-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `3022` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:3022
```

## 📝 Notes

- Install `ai/searxng` (port 8081) first for web search results.
- Point [MODELS.OLLAMA] in config.toml at your Ollama instance, or add an OpenAI API key.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
