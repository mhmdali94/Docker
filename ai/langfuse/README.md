# Langfuse

LLM observability platform — traces, evaluations, prompt versioning, and cost analytics.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/langfuse/langfuse-ubuntu.sh
chmod +x langfuse-ubuntu.sh
sudo bash langfuse-ubuntu.sh
```

## What It Installs

- **Langfuse** — LLM observability and analytics
- **PostgreSQL** — primary database

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:3006 |
| Setup | Register on first visit |

## Ports

| Port | Service |
| --- | --- |
| 3006 | Langfuse Web UI |

## Connect

Register your account at `http://<server-ip>:3006`. Then grab your project API keys and add the Langfuse SDK to your LLM application to start recording traces.
