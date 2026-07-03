# LanguageTool — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [LanguageTool](https://languagetool.org) — a private grammar, style and spell checker API (works with the official browser extensions).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/languagetool/languagetool-ubuntu.sh
chmod +x languagetool-ubuntu.sh
sudo bash languagetool-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8183` | HTTP API |

## 💻 Connect

```bash
curl -d 'text=A example' -d 'language=en-US' http://SERVER_IP:8183/v2/check
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
