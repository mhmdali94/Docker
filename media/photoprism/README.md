# Photoprism

AI-powered self-hosted photo management — browse, search, and organize your photo library (Google Photos alternative).

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/photoprism/photoprism-ubuntu.sh
chmod +x photoprism-ubuntu.sh
sudo bash photoprism-ubuntu.sh
```

## What It Installs

- **Photoprism** — photo management with AI classification

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:2342 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 2342 | Photoprism Web UI |

## Connect

Log in at `http://<server-ip>:2342`. Add your photos to `./photos` on the host (mounted at `/photoprism/originals`) then trigger an index from Library → Index.
