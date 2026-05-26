# LibreTranslate

Free and open-source machine translation API. Self-hosted alternative to Google Translate and DeepL — translate text between 30+ languages with a simple REST API.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/libretranslate/libretranslate-ubuntu.sh
chmod +x libretranslate-ubuntu.sh
sudo bash libretranslate-ubuntu.sh
```

## What It Installs

- **LibreTranslate** — Translation API with web UI

## Ports

| Port | Service |
| --- | --- |
| 5010 | LibreTranslate UI + API |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:5010` |
| API Docs | `http://<server-ip>:5010/docs` |

## Default Languages Installed

`en, ar, fr, es, de, zh, ru, ja, ko, pt, tr, it`

Add more by editing `docker-compose.yml` and updating `LT_LOAD_ONLY`.

## API Usage

```bash
# Translate text
curl -X POST http://localhost:5010/translate \
  -H "Content-Type: application/json" \
  -d '{"q":"Hello world","source":"en","target":"ar"}'

# List supported languages
curl http://localhost:5010/languages
```

## Notes

- First startup downloads language models (~2 GB) — allow 3–5 minutes
- Language models stored in `./data/`
- Powered by Argos Translate (open-source ML models)
- Add to LibreOffice, browser extensions, or any app via API
