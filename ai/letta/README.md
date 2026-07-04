# Letta — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Letta](https://www.letta.com) — build LLM agents with long-term memory (formerly MemGPT).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/letta/letta-ubuntu.sh
chmod +x letta-ubuntu.sh
sudo bash letta-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8285` | Server + API |

## 💻 Connect

```bash
http://SERVER_IP:8285
```

## 📝 Notes

- Set your LLM provider key (e.g. OPENAI_API_KEY) in docker-compose.yml, or point Letta at the ai/ollama script.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
