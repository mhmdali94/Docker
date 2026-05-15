# Node-RED

Flow-based visual programming for event-driven automation — ideal for IoT, home automation, and API wiring.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/node-red/node-red-ubuntu.sh
chmod +x node-red-ubuntu.sh
sudo bash node-red-ubuntu.sh
```

## What It Installs

- **Node-RED** — flow-based automation runtime

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:1880 |
| Auth | None (demo mode) |

## Ports

| Port | Service |
| --- | --- |
| 1880 | Node-RED Editor |

## Connect

Open `http://<server-ip>:1880` to access the flow editor. Drag nodes from the palette, connect them, and deploy. Install additional nodes via the palette manager (hamburger menu → Manage palette).

> For production, enable admin auth in `settings.js` inside the `./data` volume.
