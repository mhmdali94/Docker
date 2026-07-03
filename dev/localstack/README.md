# LocalStack — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [LocalStack](https://localstack.cloud) — a fully functional local AWS cloud emulator (S3, SQS, Lambda, DynamoDB...).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/localstack/localstack-ubuntu.sh
chmod +x localstack-ubuntu.sh
sudo bash localstack-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `4566` | Edge endpoint (all services) |

## 💻 Connect

```bash
aws --endpoint-url=http://SERVER_IP:4566 s3 ls
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
