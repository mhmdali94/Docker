# Trivy

Comprehensive vulnerability scanner for containers, filesystems, and infrastructure-as-code — lightweight and fast.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/trivy/trivy-ubuntu.sh
chmod +x trivy-ubuntu.sh
sudo bash trivy-ubuntu.sh
```

## What It Installs

- **Trivy Server** — vulnerability scanner in server mode (HTTP API)

## Credentials

| Field | Value |
| --- | --- |
| API URL | http://\<server-ip\>:4954 |
| Auth | None |

## Ports

| Port | Service |
| --- | --- |
| 4954 | Trivy HTTP API |

## Connect

Scan a container image using this server from any host:

```bash
trivy image --server http://<server-ip>:4954 nginx:latest
```

Or scan a local filesystem:
```bash
trivy fs --server http://<server-ip>:4954 /path/to/project
```
