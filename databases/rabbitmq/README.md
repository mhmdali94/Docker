# RabbitMQ — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [RabbitMQ](https://www.rabbitmq.com) — the most widely deployed open-source message broker.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/rabbitmq/rabbitmq-ubuntu.sh
chmod +x rabbitmq-ubuntu.sh
sudo bash rabbitmq-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `5672` | AMQP |
| `15672` | Management UI |

## 💻 Connect

```bash
amqp://admin:PASSWORD@SERVER_IP:5672
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
