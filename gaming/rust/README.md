# Rust Game Server

Hardcore survival multiplayer with procedurally generated maps. Powered by `linuxserver/rust`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/rust/rust-ubuntu.sh
chmod +x rust-ubuntu.sh
sudo bash rust-ubuntu.sh
```

## What It Installs

- **Rust Dedicated Server** — via `linuxserver/rust`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 28015 | TCP + UDP | Game port |
| 28016 | TCP | RCON WebUI |
| 28017 | UDP | Steam query |
| 28082 | TCP | Rust+ companion app |

## Access

In Rust: F1 → `client.connect <server-ip>:28015`

## Requirements

**Steam GSLT Token required** — get one free using App ID `252490`.

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 8 GB | 16 GB |
| CPU | 4 cores | 8+ cores |
| Disk | 15 GB | 30 GB |

## Features

- Random map seed generated at install time
- Configurable map size (1000–6000)
- RCON web interface for remote administration
- Oxide plugin support (drop plugins in `./oxide/plugins/`)
- Server data persisted in `./data/`

## Notes

- First start downloads ~7 GB — takes 15–30 minutes
- Rust must be purchased — dedicated server is free
- Map wipes: restart container with a new `+server.seed` value
- RCON WebUI available at `http://<server-ip>:28016`
- Oxide mods: place `.cs` or `.dll` files in `./oxide/plugins/`

