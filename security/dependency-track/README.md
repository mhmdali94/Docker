# Dependency-Track — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Dependency-Track](https://dependencytrack.org) — intelligent software supply-chain risk analysis (SBOM platform) — pairs with Trivy.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/dependency-track/dependency-track-ubuntu.sh
chmod +x dependency-track-ubuntu.sh
sudo bash dependency-track-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` (forced change on first login) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8247` | Web UI |
| `8246` | API server |

## 💻 Connect

```bash
http://SERVER_IP:8247
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
