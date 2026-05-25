# Hoarder

AI-powered bookmark manager with automatic tagging, full-text search, and screenshot capture. Save links, notes, and images — search everything instantly.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/hoarder/hoarder-ubuntu.sh
chmod +x hoarder-ubuntu.sh
sudo bash hoarder-ubuntu.sh
```

## What It Installs

- **Hoarder** — Bookmark manager web app
- **Meilisearch** — Full-text search engine
- **Chromium** — Headless browser for screenshots and page archiving

## Ports

| Port | Service |
| --- | --- |
| 3777 | Hoarder web interface |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:3777` |

## Default Credentials

None — the first visit creates your admin account.

## AI Tagging

Hoarder can automatically tag bookmarks using AI:

| Provider | Setup |
| --- | --- |
| OpenAI | Provide your API key during install |
| Ollama (local) | Set `OLLAMA_BASE_URL` in docker-compose.yml |

To enable Ollama after install, edit `docker-compose.yml` and add:
```yaml
environment:
  OLLAMA_BASE_URL: http://<ollama-host>:11434
  INFERENCE_TEXT_MODEL: llama3.2:3b
```

## Browser Extension

Install the Hoarder browser extension (Chrome/Firefox) to save bookmarks with one click from any page.

## Notes

- Screenshots and archived pages stored in `./data/`
- Meilisearch index stored in `./meilisearch/`
- Supports RSS feeds, highlights, and notes
- REST API available for automation
