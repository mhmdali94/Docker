# Apache Kafka — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Apache Kafka](https://kafka.apache.org) — the distributed event streaming platform (single-node KRaft) with a web UI.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/kafka/kafka-ubuntu.sh
chmod +x kafka-ubuntu.sh
sudo bash kafka-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `9094` | Kafka (external listener) |
| `8240` | Kafka UI |

## 💻 Connect

```bash
kafka-console-producer --bootstrap-server SERVER_IP:9094 --topic test
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
