# Ollama — Local AI Models

Run AI models entirely on your own server. No cloud, no API keys, no usage fees.

## What is Ollama?

Ollama is the **runtime engine** that executes AI models locally. You can't skip it — it's what actually runs the model. Think of it like a video player: the model is the video file, Ollama is the player.

The only large download is the **model itself**. Everything else is minimal.

---

## Install

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/ollama/ollama-ubuntu.sh
chmod +x ollama-ubuntu.sh
sudo bash ollama-ubuntu.sh
```

The installer walks you through everything before downloading anything:

1. **Your hardware** — CPU / NVIDIA GPU / AMD GPU + how much RAM or VRAM you have
2. **Install type** — Ollama only, or Ollama + Open WebUI
3. **Model selection** — pick exactly what you need, compatibility shown per model
4. **Download summary** — total size + disk space check before anything starts

Nothing downloads until you confirm.

---

## Install Modes

| Mode | Ollama size | Use when |
| --- | --- | --- |
| Native (direct on server) | ~50 MB binary | You just want to run models |
| Docker | ~1.5 GB image | You want container management |

> **Just want one model?** Native install is the right choice. Two commands:
> ```bash
> curl -fsSL https://ollama.com/install.sh | sh
> ollama pull qwen2.5-coder:7b
> ```

---

## Open WebUI (optional)

A ChatGPT-like browser interface on top of Ollama. **Not required.**

Skip it if you're using Ollama via API or connecting it to a VS Code extension (Cline, Continue, KiloCode). Install it if you want a chat UI in the browser.

| Service | Port |
| --- | --- |
| Open WebUI | `http://<server-ip>:3210` |
| Ollama API | `http://<server-ip>:11434` |

---

## GPU Support

The installer detects your GPU type and configures Docker automatically.

| Hardware | What the installer does |
| --- | --- |
| NVIDIA (CUDA) | Checks for NVIDIA Container Toolkit, offers to install it, enables `--gpus all` |
| AMD (ROCm) | Uses `ollama/ollama:rocm` image, passes `/dev/kfd` + `/dev/dri` |
| CPU only | Standard setup, no extras |

GPU users get 5–10× faster responses. For daily coding use, GPU is strongly recommended.

---

## Model Compatibility

The installer shows a live compatibility table based on your hardware:

| Indicator | Meaning |
| --- | --- |
| ✅ OK | Fits your RAM / VRAM — runs well |
| ⚠️ Needs X GB | Exceeds your RAM — will use disk swap, very slow |
| ❌ Need X GB VRAM | Exceeds GPU VRAM — GPU hard limit |

**CPU users can still install ⚠️ models.** The installer will warn you first:

```
  ⚠️   CAUTION — Models exceed your available RAM
  ║  qwen2.5-coder:14b  needs 16 GB — you have 8 GB
  ║
  ║  These models WILL run but will spill into disk swap.
  ║    • Very slow responses (minutes per reply)
  ║    • High disk I/O — SSD strongly recommended
  ║    • Risk of OOM crash on severely under-spec servers
```

You can confirm and install anyway, or decline to remove them from your selection.

---

## Models

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

---

## Disk Space Check

Before downloading, the installer calculates the total required space (with a 20% buffer) and checks your available disk space:

```
  │  Space required  (with 20% buffer): ~8 GB         │
  │  Space available (on /var/lib/docker): 3 GB        │
  │  ❌ Not enough space — free up ~5 GB first.        │
```

If there isn't enough space, it warns you with exactly how many GB to free up.

---

## Swap & Memory — Why It Matters

Ollama calculates available memory using `MemFree + Buffers` — **not** the `MemAvailable` figure that Linux and `free -h` report. On a busy server, `MemFree` can be very low even when the system has gigabytes of reclaimable page cache, causing Ollama to refuse loading a model with an error like:

```
Error: model requires more system memory (4.3 GiB) than is available (3.0 GiB)
```

The installer handles this in two ways:

**1 — Sets up a swapfile (recommended, asked during install)**

Ollama counts swap as available memory. An 8 GB swapfile on an 8 GB server gives Ollama the headroom it needs and prevents OOM crashes when running large models.

```bash
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab   # persist across reboots
```

**2 — Drops the page cache before pulling models**

Releases cached pages so `MemFree` jumps from a few hundred MB to several GB, giving Ollama an accurate picture of what RAM is actually available.

```bash
sync && echo 3 > /proc/sys/vm/drop_caches
```

If you hit the memory error on an existing install, run both commands above manually then retry.

---

## Managing Models

```bash
# List installed models
ollama list                                       # native
docker exec ollama ollama list                    # docker

# Pull a model
ollama pull qwen2.5-coder:7b                      # native
docker exec ollama ollama pull qwen2.5-coder:7b   # docker

# Remove a model
ollama rm qwen2.5-coder:7b                        # native
docker exec ollama ollama rm qwen2.5-coder:7b     # docker
```

---

## Connecting VS Code Extensions (Cline, Continue, KiloCode)

Use **OpenAI Compatible** as the provider:

| Field | Value |
| --- | --- |
| Base URL | `http://<server-ip>:11434/v1` |
| API Key | `ollama` (any non-empty value) |
| Model ID | e.g. `qwen2.5-coder:7b` |

> The `/v1` suffix is required.

**Recommended models for VS Code extensions:**

| Model | Min VRAM | Best for |
| --- | --- | --- |
| `qwen2.5-coder:7b` | 6 GB | Fast everyday coding |
| `qwen2.5-coder:14b` | 10 GB | Stronger, larger context |
| `deepseek-coder-v2:16b` | 12 GB | Top quality |
| `devstral:24b` | 16 GB | Agentic multi-file tasks |

---

## Notes

- Models persist across restarts (`~/.ollama` for native · `./ollama/` for Docker)
- On CPU, 7B models are usable but not fast — GPU strongly recommended for daily use
- Running models larger than your RAM works but is very slow (disk swap) — SSD required
- Open WebUI also supports external APIs (OpenAI, Anthropic) as an alternative to local models
