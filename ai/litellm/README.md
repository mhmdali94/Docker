# LiteLLM — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [LiteLLM](https://litellm.ai) — an OpenAI-compatible proxy for 100+ LLM providers (including your local Ollama).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/litellm/litellm-ubuntu.sh
chmod +x litellm-ubuntu.sh
sudo bash litellm-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Master key | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `4001` | Proxy + UI |

## 💻 Connect

```bash
curl http://SERVER_IP:4001/v1/models -H "Authorization: Bearer sk-..."
```

## 📝 Notes

- Add provider API keys / model routes via environment or a config file — see LiteLLM docs.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
