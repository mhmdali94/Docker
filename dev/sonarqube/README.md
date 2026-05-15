# SonarQube — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [SonarQube Community Edition](https://www.sonarsource.com/products/sonarqube/) — the leading open-source platform for code quality and security analysis (SAST) across 30+ programming languages.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/sonarqube/sonarqube-ubuntu.sh
chmod +x sonarqube-ubuntu.sh
sudo bash sonarqube-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` (forced change on first login) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9000` | SonarQube Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:9000

# Analyze a project (after creating a token in SonarQube UI)
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://SERVER_IP:9000 \
  -Dsonar.login=YOUR_TOKEN
```

## ⚙️ Notes

- SonarQube takes ~2 minutes to start on first boot (Elasticsearch initialization)
- Requires `vm.max_map_count=524288` — the installer sets this automatically
- Change the default `admin/admin` password immediately after first login

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
