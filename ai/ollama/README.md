# Ollama — Local AI Models

Run AI models entirely on your own server. No cloud, no API keys, no usage fees.

## What is Ollama?

Ollama is the **runtime engine** that runs AI models locally. You can't skip it — it's what actually executes the model. Think of it like a video player: the model is the video file, Ollama is the player.

The only large download is the **model itself**. Everything else is minimal.

---

## Install Modes

### Native Install — Recommended if you just want a model

Ollama binary is ~50 MB. Fast, lightweight, no Docker required.

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/ollama/ollama-ubuntu.sh
chmod +x ollama-ubuntu.sh
sudo bash ollama-ubuntu.sh
# → choose: Native install
```

Or manually in 2 commands:

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5-coder:7b
```

### Docker Install — If you want containers and easy management

Pulls the full Ollama Docker image (~1.5 GB). Use this if you need portability, want to manage it with Compose, or are running multiple services together.

```bash
sudo bash ollama-ubuntu.sh
# → choose: Docker install
```

---

## What Gets Downloaded

| What | Native | Docker |
| --- | --- | --- |
| Ollama runtime | ~50 MB | ~1.5 GB image |
| Open WebUI (optional) | — | ~2.5 GB image |
| Your chosen model | same | same |

The model is always the biggest download — see sizes below.

---

## Open WebUI (optional)

A ChatGPT-like interface on top of Ollama. **Not required** — Ollama works perfectly as a standalone API without it.

Install it if you want a browser-based chat UI. Skip it if you're using Ollama headlessly or connecting it to VS Code / Cline / Continue.

| Service | Port |
| --- | --- |
| Open WebUI | `http://<server-ip>:3210` |
| Ollama API | `http://<server-ip>:11434` |

---

## Models

The installer shows a compatibility table based on your hardware. Only models that fit your RAM or VRAM are marked ✅.

### General Purpose

| # | Model | Download | Min RAM | Min VRAM | CPU Speed |
| --- | --- | --- | --- | --- | --- |
| 1 | `llama3.2:3b` | ~2 GB | 8 GB | 3 GB | Fast |
| 2 | `llama3.2:1b` | ~1 GB | 4 GB | 2 GB | Very Fast |
| 3 | `mistral:7b` | ~4 GB | 8 GB | 6 GB | Medium |
| 4 | `gemma3:4b` | ~3 GB | 6 GB | 4 GB | Fast |
| 5 | `qwen2.5:7b` | ~5 GB | 8 GB | 6 GB | Medium |

### Coding

| # | Model | Download | Min RAM | Min VRAM | CPU Speed |
| --- | --- | --- | --- | --- | --- |
| 6 | `qwen2.5-coder:7b` | ~5 GB | 8 GB | 6 GB | Medium |
| 7 | `qwen2.5-coder:14b` | ~9 GB | 16 GB | 10 GB | Slow |
| 8 | `deepseek-coder-v2:16b` | ~10 GB | 20 GB | 12 GB | Slow |
| 9 | `codellama:7b` | ~4 GB | 8 GB | 6 GB | Medium |
| 10 | `codellama:13b` | ~8 GB | 16 GB | 10 GB | Slow |
| 11 | `codegemma:7b` | ~5 GB | 8 GB | 6 GB | Medium |
| 12 | `starcoder2:7b` | ~4 GB | 8 GB | 6 GB | Medium |
| 13 | `devstral:24b` | ~15 GB | 32 GB | 16 GB | Very Slow |

### Reasoning / Math

| # | Model | Download | Min RAM | Min VRAM | CPU Speed |
| --- | --- | --- | --- | --- | --- |
| 14 | `deepseek-r1:7b` | ~5 GB | 8 GB | 6 GB | Medium |
| 15 | `deepseek-r1:14b` | ~9 GB | 16 GB | 10 GB | Slow |
| 16 | `deepseek-r1:32b` | ~20 GB | 40 GB | 20 GB | Very Slow |
| 17 | `qwq:32b` | ~20 GB | 40 GB | 20 GB | Very Slow |
| 18 | `phi4:14b` | ~9 GB | 16 GB | 10 GB | Slow |

### Multilingual (Arabic support)

| # | Model | Download | Min RAM | Min VRAM | CPU Speed |
| --- | --- | --- | --- | --- | --- |
| 19 | `aya-expanse:8b` | ~5 GB | 10 GB | 6 GB | Medium |
| 20 | `qwen2.5:14b` | ~9 GB | 16 GB | 10 GB | Slow |

> **CPU Speed** = inference speed on CPU only. GPU users get 5–10× faster responses regardless of rating.

---

## GPU Support

The installer detects your hardware and configures everything automatically.

| GPU | What changes |
| --- | --- |
| NVIDIA (CUDA) | Installs NVIDIA Container Toolkit, enables `--gpus all` |
| AMD (ROCm) | Uses `ollama/ollama:rocm` image, passes `/dev/kfd` + `/dev/dri` |
| CPU only | Standard setup, no extras needed |

**Minimum RAM / VRAM guide:**

| Model size | CPU RAM | GPU VRAM |
| --- | --- | --- |
| 1–3B | 4–8 GB | 2–3 GB |
| 7–8B | 8–10 GB | 6 GB |
| 13–14B | 16 GB | 10 GB |
| 16–24B | 20–32 GB | 12–16 GB |
| 32B+ | 40 GB+ | 20 GB+ |

---

## Managing Models

```bash
# List installed models
ollama list                                      # native
docker exec ollama ollama list                   # docker

# Pull a model
ollama pull qwen2.5-coder:7b                     # native
docker exec ollama ollama pull qwen2.5-coder:7b  # docker

# Remove a model
ollama rm qwen2.5-coder:7b                       # native
docker exec ollama ollama rm qwen2.5-coder:7b    # docker
```

---

## Connecting VS Code Extensions (Cline, Continue, KiloCode)

Use **OpenAI Compatible** as the provider:

| Field | Value |
| --- | --- |
| Base URL | `http://<server-ip>:11434/v1` |
| API Key | `ollama` (any non-empty value works) |
| Model ID | e.g. `qwen2.5-coder:7b` |

> The `/v1` suffix is required.

**Recommended models for VS Code extensions:**

| Model | VRAM | Best for |
| --- | --- | --- |
| `qwen2.5-coder:7b` | 6 GB | Fast everyday coding |
| `qwen2.5-coder:14b` | 10 GB | Stronger, larger context |
| `deepseek-coder-v2:16b` | 12 GB | Top quality |
| `devstral:24b` | 16 GB | Agentic multi-file tasks |

---

## Notes

- Models persist across restarts (stored in `~/.ollama` for native, `./ollama/` for Docker)
- On CPU, 7B models are usable but not fast — GPU is strongly recommended for daily use
- Open WebUI also supports connecting external APIs (OpenAI, Anthropic) if you want a unified chat interface
