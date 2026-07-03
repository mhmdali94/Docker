# Weaviate — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Weaviate](https://weaviate.io) — an open-source AI-native vector database.

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ai/weaviate/weaviate-ubuntu.sh
chmod +x weaviate-ubuntu.sh
sudo bash weaviate-ubuntu.sh
```

## 🔑 Credentials

| Setup | Completed on first visit |
|-------|--------------------------|

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8142` | REST API |
| `50051` | gRPC |

## 💻 Connect

```bash
curl http://SERVER_IP:8142/v1/meta
```

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
