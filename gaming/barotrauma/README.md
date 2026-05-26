# Barotrauma Server

2D co-op submarine survival horror set in Europa's ocean. Powered by `linuxserver/barotrauma`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/barotrauma/barotrauma-ubuntu.sh
chmod +x barotrauma-ubuntu.sh
sudo bash barotrauma-ubuntu.sh
```

## What It Installs

- **Barotrauma Dedicated Server** — via `linuxserver/barotrauma`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 27015 | UDP | Game port |
| 27016 | UDP | Steam query |

## Access

In Barotrauma: Play → Join Server → filter by name or Direct Connect → `<server-ip>:27015`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 2 GB | 4 GB |
| CPU | 2 cores | 4 cores |
| Disk | 3 GB | 6 GB |

## Features

- Karma system enabled (punishes griefers)
- Spectating allowed
- Auto-restart on crash
- Optional server password
- Save data and configs persisted in `./data/`

## Notes

- Barotrauma must be purchased — dedicated server is free
- Server config at `./data/serversettings.xml`
- Campaign saves at `./data/`
- Admin access in-game: type owner key in the console

