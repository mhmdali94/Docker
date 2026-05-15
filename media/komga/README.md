# Komga

Self-hosted comic and manga server with a web reader and OPDS support.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/media/komga/komga-ubuntu.sh
chmod +x komga-ubuntu.sh
sudo bash komga-ubuntu.sh
```

## What It Installs

- **Komga** — comic/manga library server

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8076 |
| Setup | Register on first visit |

## Ports

| Port | Service |
| --- | --- |
| 8076 | Komga Web UI |

## Connect

Register your admin account at `http://<server-ip>:8076`. Create a library pointing to a directory that contains your comic/manga files (CBZ, CBR, PDF, or folder-based series). Komga also supports the Kavita and Opds-PS apps.
