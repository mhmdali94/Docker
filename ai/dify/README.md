# Dify

Visual LLM app builder with RAG pipelines, agent workflows, and multi-model support.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/dify/dify-ubuntu.sh
chmod +x dify-ubuntu.sh
sudo bash dify-ubuntu.sh
```

## What It Installs

- **Dify** — LLM application platform
- **PostgreSQL** — primary database
- **Redis** — cache and task queue
- **Sandbox** — secure code execution

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:3050 |
| Setup | Web wizard on first visit |

## Ports

| Port | Service |
| --- | --- |
| 3050 | Dify Web UI |

## Connect

Open `http://<server-ip>:3050` and complete the admin account setup wizard. Then add your LLM API keys (OpenAI, Anthropic, Ollama, etc.) under Settings → Model Providers.
