# DefectDojo — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [DefectDojo](https://www.defectdojo.com/) — open-source vulnerability management platform. Import scanner results, track findings lifecycle, manage remediations, and measure your security posture over time.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/security/defectdojo/defectdojo-ubuntu.sh
chmod +x defectdojo-ubuntu.sh
sudo bash defectdojo-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8092` | DefectDojo Web UI |

## 💻 Connect

```bash
# Web UI
http://SERVER_IP:8092

# Import findings via API
curl -X POST http://SERVER_IP:8092/api/v2/import-scan/ \
  -H "Authorization: Token YOUR_API_TOKEN" \
  -F "scan_type=ZAP Scan" \
  -F "file=@zap-report.xml" \
  -F "engagement=1"
```

## 💡 Supported Scanners

DefectDojo imports results from 100+ scanners including Burp Suite, OWASP ZAP, Nessus, Trivy, Semgrep, SonarQube, and more.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
