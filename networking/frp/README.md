# FRP (Fast Reverse Proxy)

High-performance reverse proxy for exposing local services through a public server — TCP, UDP, HTTP, and HTTPS tunnels.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/networking/frp/frp-ubuntu.sh
chmod +x frp-ubuntu.sh
sudo bash frp-ubuntu.sh
```

## What It Installs

- **frps** — FRP server (runs on the public-facing host)

## Credentials

| Field | Value |
| --- | --- |
| Dashboard URL | http://\<server-ip\>:7500 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 7000 | FRP proxy bind port |
| 7500 | frps dashboard |

## Connect

Run this installer on your public server. Then on the client machine, run `frpc` pointing to `<server-ip>:7000` with the matching token to establish a tunnel.
