# Kopia

Fast, encrypted, deduplicated backup tool with a web UI — backs up to local disk, S3, B2, and more.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/backup/kopia/kopia-ubuntu.sh
chmod +x kopia-ubuntu.sh
sudo bash kopia-ubuntu.sh
```

## What It Installs

- **Kopia** — backup client + server with web UI

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:51515 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 51515 | Kopia Web UI |

## Connect

Log in at `http://<server-ip>:51515`. The local filesystem repository is pre-initialized at `./repository`. Add backup policies, set schedules, and connect remote repositories (S3, B2, Azure) from the UI.
