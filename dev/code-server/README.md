# Code-server

VS Code running in the browser — full IDE accessible from any device over HTTP.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/code-server/code-server-ubuntu.sh
chmod +x code-server-ubuntu.sh
sudo bash code-server-ubuntu.sh
```

## What It Installs

- **Code-server** — browser-based VS Code IDE

## Credentials

| Field | Value |
| --- | --- |
| URL | http://\<server-ip\>:8094 |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 8094 | Code-server Web IDE |

## Connect

Open `http://<server-ip>:8094` and enter the password shown at the end of the installer. The workspace is mounted at `/root` inside the container.
