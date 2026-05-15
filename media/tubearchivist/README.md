# Tubearchivist

Self-hosted YouTube media server — subscribe to channels, download videos, and browse your archive.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/tubearchivist/tubearchivist-ubuntu.sh
chmod +x tubearchivist-ubuntu.sh
sudo bash tubearchivist-ubuntu.sh
```

## What It Installs

- **Tubearchivist** — YouTube archive manager
- **Elasticsearch** — search index
- **Redis** — task queue

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8098 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8098 | Tubearchivist Web UI |

## Connect

Log in at `http://<server-ip>:8098`. Add YouTube channel or playlist URLs to start downloading. Requires a YouTube cookies file for age-restricted or member content.
