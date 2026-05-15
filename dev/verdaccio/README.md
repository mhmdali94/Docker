# Verdaccio

Lightweight private npm registry — proxy, cache, and publish packages locally.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/verdaccio/verdaccio-ubuntu.sh
chmod +x verdaccio-ubuntu.sh
sudo bash verdaccio-ubuntu.sh
```

## What It Installs

- **Verdaccio** — private npm registry with upstream proxy

## Credentials

| Field | Value |
| --- | --- |
| Registry URL | http://\<server-ip\>:4873 |
| Auth | No auth in demo mode |

## Ports

| Port | Service |
| --- | --- |
| 4873 | Verdaccio Web UI + npm registry |

## Connect

Point npm to your private registry:

```bash
npm set registry http://<server-ip>:4873
```

Or use it for a single install: `npm install --registry http://<server-ip>:4873 <package>`
