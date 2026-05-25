# ComfyUI

Stable Diffusion image generation with a powerful node-based workflow interface. Generate images locally — no cloud, no subscription.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/comfyui/comfyui-ubuntu.sh
chmod +x comfyui-ubuntu.sh
sudo bash comfyui-ubuntu.sh
```

## What It Installs

- **ComfyUI** — Node-based Stable Diffusion UI with full workflow control

## Ports

| Port | Service |
| --- | --- |
| 8188 | ComfyUI web interface |

## Access

| | URL |
| --- | --- |
| ComfyUI | `http://<server-ip>:8188` |

## Models

ComfyUI does not ship with models — download them separately and place in `./models/`:

| Folder | Content |
| --- | --- |
| `./models/checkpoints/` | Main models (SDXL, SD1.5, Flux, etc.) |
| `./models/loras/` | LoRA fine-tunes |
| `./models/vae/` | VAE files |
| `./output/` | Generated images |

Popular model sources: [CivitAI](https://civitai.com) · [Hugging Face](https://huggingface.co)

## GPU Support

The installer asks whether to enable NVIDIA GPU acceleration. GPU is strongly recommended — CPU generation is very slow (minutes per image vs seconds on GPU).

For NVIDIA GPU, the NVIDIA Container Toolkit must be installed first:
```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt update && apt install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker && systemctl restart docker
```

## Notes

- First startup downloads ComfyUI and dependencies — takes several minutes
- No credentials needed — open access on first visit
- Workflows are saved as JSON and can be shared/imported
- Supports SDXL, SD 1.5, Flux, ControlNet, IP-Adapter, and most community models
