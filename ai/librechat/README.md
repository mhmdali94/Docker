# LibreChat

A unified AI chat interface supporting OpenAI, Claude, Gemini, Ollama, and 10+ providers — all in one self-hosted ChatGPT-like UI.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/librechat/librechat-ubuntu.sh
chmod +x librechat-ubuntu.sh
sudo bash librechat-ubuntu.sh
```

## What It Installs

- **LibreChat** — Multi-provider AI chat interface
- **MongoDB** — Database for conversations and users

## Ports

| Port | Service |
| --- | --- |
| 3080 | LibreChat web interface |

## Access

| | URL |
| --- | --- |
| LibreChat | `http://<server-ip>:3080` |

## Default Credentials

No default credentials — register an account on first visit. The first user gets admin access.

## Supported AI Providers

Add API keys in **Settings → API Keys** after logging in:

| Provider | Key needed |
| --- | --- |
| OpenAI (GPT-4, GPT-3.5) | OpenAI API key |
| Anthropic (Claude) | Anthropic API key |
| Google (Gemini) | Google AI API key |
| Ollama (local) | Server URL only, no key |
| Azure OpenAI | Azure credentials |
| Mistral, Groq, Cohere | Their respective API keys |

## Notes

- Conversations are stored locally in MongoDB
- Supports plugins, image generation (DALL-E), and code interpreter
- Connect to your local Ollama instance via `http://host-ip:11434`
- Registration can be disabled via the `ALLOW_REGISTRATION` env var
