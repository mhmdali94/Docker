# Minecraft Bedrock Edition Server

Cross-platform Minecraft server for mobile (PE), Windows 10/11, Xbox, Switch, and PlayStation. Powered by `itzg/minecraft-bedrock-server`.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/gaming/minecraft-bedrock/minecraft-bedrock-ubuntu.sh
chmod +x minecraft-bedrock-ubuntu.sh
sudo bash minecraft-bedrock-ubuntu.sh
```

## What It Installs

- **Minecraft Bedrock Dedicated Server** — via `itzg/minecraft-bedrock-server`

## Ports

| Port | Protocol | Service |
| --- | --- | --- |
| 19132 | UDP | Game port (IPv4) |
| 19133 | UDP | Game port (IPv6) |

## Access

In Minecraft (Bedrock): Servers → Add Server → `<server-ip>:19132`

## Hardware Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| RAM | 1 GB | 2 GB |
| CPU | 2 cores | 4 cores |
| Disk | 2 GB | 5 GB |

## Cross-Platform Support

Works with:
- Android / iOS (Minecraft PE)
- Windows 10 / 11 Edition
- Xbox One / Series
- Nintendo Switch
- PlayStation 4 / 5

## Features

- Auto-downloads latest Bedrock server binary
- Xbox Live authentication (online mode)
- Configurable game mode and difficulty
- World data persisted in `./data/worlds/`

## Notes

- Bedrock dedicated server is free — clients need the game purchased
- `ONLINE_MODE: "false"` disables Xbox auth (allows LAN/unofficial clients)
- Server properties at `./data/server.properties`
- Cannot run Java Edition plugins/mods — use the Java server for those

