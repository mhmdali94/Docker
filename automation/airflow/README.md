# Apache Airflow — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Apache Airflow](https://airflow.apache.org) — the data-pipeline orchestrator (standalone demo mode with SQLite).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/automation/airflow/airflow-ubuntu.sh
chmod +x airflow-ubuntu.sh
sudo bash airflow-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Shown in `docker logs airflow` |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8210` | Web UI |

## 💻 Connect

```bash
http://SERVER_IP:8210
```

## 📝 Notes

- Standalone mode is for evaluation — use CeleryExecutor + Postgres for real workloads.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
