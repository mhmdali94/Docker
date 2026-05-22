# Ollama + Open WebUI

Run local LLMs entirely on your own server with a ChatGPT-like web interface. The installer lets you pick models interactively during setup — including specialized coding and reasoning models.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/ollama/ollama-ubuntu.sh
chmod +x ollama-ubuntu.sh
sudo bash ollama-ubuntu.sh
```

## What It Installs

- **Ollama** — local LLM runtime and API server (listens on all interfaces via `OLLAMA_HOST=0.0.0.0`)
- **Open WebUI** — ChatGPT-like web interface connected to Ollama

## Ports

| Port | Service |
| --- | --- |
| 3210 | Open WebUI (chat interface) |
| 11434 | Ollama API |

## Access

| | URL |
| --- | --- |
| Open WebUI | `http://<server-ip>:3210` |
| Ollama API | `http://<server-ip>:11434` |

Create your admin account on first visit to Open WebUI.

## Model Selection (during install)

The installer presents an interactive menu. Enter numbers separated by spaces to pull multiple models.

Example: `1 6 14` pulls `llama3.2:3b` + `qwen2.5-coder:7b` + `deepseek-r1:7b`

Enter `0` to skip and pull models manually later.

### General Purpose

| # | Model | Size | Notes |
| --- | --- | --- | --- |
| 1 | `llama3.2:3b` | ~2 GB | Fast, general chat |
| 2 | `llama3.2:1b` | ~1 GB | Very fast, lightweight |
| 3 | `mistral:7b` | ~4 GB | Strong reasoning |
| 4 | `gemma3:4b` | ~3 GB | Google Gemma 3, efficient |
| 5 | `qwen2.5:7b` | ~5 GB | Multilingual + Arabic |

### Coding

| # | Model | Size | Notes |
| --- | --- | --- | --- |
| 6 | `qwen2.5-coder:7b` | ~5 GB | Best mid-size coding model |
| 7 | `qwen2.5-coder:14b` | ~9 GB | Larger, stronger coder |
| 8 | `deepseek-coder-v2:16b` | ~10 GB | Top overall coding model |
| 9 | `codellama:7b` | ~4 GB | Meta Code Llama 7B |
| 10 | `codellama:13b` | ~8 GB | Meta Code Llama 13B |
| 11 | `codegemma:7b` | ~5 GB | Google code model |
| 12 | `starcoder2:7b` | ~4 GB | StarCoder2, multi-language |
| 13 | `devstral:24b` | ~15 GB | Mistral DevStral, agentic coding |

### Reasoning / Math

| # | Model | Size | Notes |
| --- | --- | --- | --- |
| 14 | `deepseek-r1:7b` | ~5 GB | Chain-of-thought reasoning |
| 15 | `deepseek-r1:14b` | ~9 GB | Strong reasoning + code |
| 16 | `deepseek-r1:32b` | ~20 GB | Best open reasoning model |
| 17 | `qwq:32b` | ~20 GB | Qwen QwQ reasoning |
| 18 | `phi4:14b` | ~9 GB | Microsoft Phi-4 reasoning |

### Multilingual (Arabic support)

| # | Model | Size | Notes |
| --- | --- | --- | --- |
| 19 | `aya-expanse:8b` | ~5 GB | Cohere Aya, 23 languages incl. Arabic |
| 20 | `qwen2.5:14b` | ~9 GB | Strong Arabic + reasoning |

## Pull Models Manually

```bash
# List installed models
docker exec ollama ollama list

# Pull a model
docker exec ollama ollama pull qwen2.5-coder:7b

# Remove a model
docker exec ollama ollama rm <model-name>
```

## Connecting VS Code Extensions (KiloCode, Cline, Continue)

Ollama exposes an OpenAI-compatible API. Use **OpenAI Compatible** as the provider in your extension:

| Field | Value |
| --- | --- |
| Provider | OpenAI Compatible |
| Base URL | `http://<server-ip>:11434/v1` |
| API Key | `ollama` (any non-empty value) |
| Model ID | e.g. `qwen2.5-coder:7b` |

> The `/v1` suffix is required — the extension appends `/chat/completions` to whatever base URL you set.

**Recommended coding models for VS Code extensions:**

| Model | RAM needed | Best for |
| --- | --- | --- |
| `qwen2.5-coder:7b` | 8 GB | Fast everyday coding |
| `qwen2.5-coder:14b` | 16 GB | Stronger, larger context |
| `deepseek-coder-v2:16b` | 20 GB | Top quality |
| `devstral:24b` | 32 GB | Agentic multi-file tasks |

## Notes

- Models are stored in `./ollama` and persist across container restarts
- Minimum RAM: 8 GB for 7B models · 16 GB for 13–16B models · 32 GB+ for 32B models
- GPU acceleration is supported — see the [Ollama Docker docs](https://hub.docker.com/r/ollama/ollama) for NVIDIA/AMD setup
- Open WebUI also supports connecting external APIs (OpenAI, Anthropic) alongside local models
