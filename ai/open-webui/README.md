# Open WebUI — Auto-Installer

**Made by:** Mohammed Ali Elshikh | [prismatechwork.com](https://prismatechwork.com)

> ⚠️ FOR DEMO / TESTING PURPOSES ONLY — not intended for production use.

## What is Open WebUI?

Open WebUI is a self-hosted, ChatGPT-style interface for running LLMs locally via Ollama or any OpenAI-compatible API.

## What this script installs

| Component  | Image                                | Port |
|------------|--------------------------------------|------|
| Open WebUI | `ghcr.io/open-webui/open-webui:main` | 3000 |

## Requirements

- Ubuntu 22.04 or 24.04 — root access

## Usage

```bash
sudo bash open-webui-ubuntu.sh
```

Open `http://<server-ip>:3000` and create your admin account on first visit.

## Connect to Ollama

Settings → Connections → set Ollama URL to `http://host.docker.internal:11434`

## Support

☕ USDT (TRC-20): `TCSZTkXvhibdrFre5sdTsFLRQ6d6yQkd2i`
