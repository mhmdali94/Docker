# TimescaleDB — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [TimescaleDB](https://www.timescale.com) — PostgreSQL for time-series — hypertables, continuous aggregates, compression.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/timescaledb/timescaledb-ubuntu.sh
chmod +x timescaledb-ubuntu.sh
sudo bash timescaledb-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `postgres` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5433` | PostgreSQL (mapped from 5432) |

## 💻 Connect

```bash
psql -h SERVER_IP -p 5433 -U postgres
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
