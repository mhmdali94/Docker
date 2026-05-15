# OpenVAS / Greenbone

Full vulnerability scanner — network scans, CVE detection, and security audit reports.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/openvas/openvas-ubuntu.sh
chmod +x openvas-ubuntu.sh
sudo bash openvas-ubuntu.sh
```

## What It Installs

- **OpenVAS / Greenbone Community** — vulnerability management platform

## Credentials

| Field | Value |
| --- | --- |
| URL | https://\<server-ip\>:9392 |
| Username | admin |
| Password | Generated at install |

## Ports

| Port | Service |
| --- | --- |
| 9392 | Greenbone Web UI (HTTPS) |

## Connect

> **Note:** First startup takes 15–30 minutes for NVT feed synchronization. The web UI will not be responsive until the sync completes.

Accept the self-signed SSL warning and log in at `https://<server-ip>:9392`. Create a new scan task, add your target IPs, and run.
