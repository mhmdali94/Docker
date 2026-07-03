# Milvus — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Milvus](https://milvus.io) — a cloud-native vector database for AI applications at scale.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/milvus/milvus-ubuntu.sh
chmod +x milvus-ubuntu.sh
sudo bash milvus-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `19530` | gRPC/HTTP API |

## 💻 Connect

```bash
pymilvus: MilvusClient(uri='http://SERVER_IP:19530')
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
