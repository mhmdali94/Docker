# LocalAI

OpenAI-compatible self-hosted API for running LLMs, image generation, and audio models locally without a GPU.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/localai/localai-ubuntu.sh
chmod +x localai-ubuntu.sh
sudo bash localai-ubuntu.sh
```

## What It Installs

- **LocalAI** — drop-in OpenAI API replacement running entirely on your hardware

## Credentials

| Field | Value |
| --- | --- |
| API URL | http://\<server-ip\>:8085/v1 |
| Auth | None (demo mode) |

## Ports

| Port | Service |
| --- | --- |
| 8085 | LocalAI API + Web UI |

## Connect

After install, pull a model via the web UI at `http://<server-ip>:8085` or with:

```bash
curl http://<server-ip>:8085/models/apply -d '{"id":"huggingface@TheBloke/Mistral-7B-Instruct-v0.1-GGUF/mistral-7b-instruct-v0.1.Q4_K_M.gguf"}'
```

Point any OpenAI-compatible client to `http://<server-ip>:8085/v1`.
