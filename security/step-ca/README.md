# step-ca — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [step-ca](https://smallstep.com/docs/step-ca/) — a private online certificate authority — issue internal TLS certs (ACME supported).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/step-ca/step-ca-ubuntu.sh
chmod +x step-ca-ubuntu.sh
sudo bash step-ca-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| CA password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9015` | CA API (HTTPS) |

## 💻 Connect

```bash
step ca bootstrap --ca-url https://SERVER_IP:9015 --fingerprint <fingerprint>
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
