# Whisper ASR

Local speech-to-text API powered by OpenAI's Whisper model. Transcribe audio files in 99 languages — no cloud, no API key.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/whisper/whisper-ubuntu.sh
chmod +x whisper-ubuntu.sh
sudo bash whisper-ubuntu.sh
```

## What It Installs

- **Whisper ASR Webservice** — REST API wrapping OpenAI Whisper with faster-whisper engine

## Ports

| Port | Service |
| --- | --- |
| 9000 | Whisper REST API |

## Access

| | URL |
| --- | --- |
| API | `http://<server-ip>:9000` |
| Swagger Docs | `http://<server-ip>:9000/docs` |

## Models

The installer lets you choose the model at setup time:

| Model | Size | Speed | Accuracy |
| --- | --- | --- | --- |
| tiny | ~75 MB | Fastest | Low |
| base | ~145 MB | Fast | Good |
| small | ~466 MB | Medium | Better |
| medium | ~1.5 GB | Slow | High |
| large | ~3 GB | Slowest | Best |

## API Usage

```bash
# Transcribe an audio file
curl -X POST http://<server-ip>:9000/asr \
  -F "audio_file=@recording.mp3"

# With language hint (faster)
curl -X POST "http://<server-ip>:9000/asr?language=ar" \
  -F "audio_file=@recording.mp3"

# Get word-level timestamps
curl -X POST "http://<server-ip>:9000/asr?word_timestamps=true" \
  -F "audio_file=@recording.mp3"
```

Supported formats: mp3, wav, m4a, ogg, flac, mp4, webm

## Notes

- Pure REST API — no web UI (use the `/docs` Swagger page to test interactively)
- Models are cached in `./models/` and persist across restarts
- Arabic, English, French, and 96 other languages supported
- Integrate with n8n, Make, or any HTTP client
