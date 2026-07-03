# Supabase (self-hosted) — Docker Setup

> ⚠️ **FOR DEMO / TESTING PURPOSES ONLY — NOT INTENDED FOR PRODUCTION USE.**

Automated installer for [Supabase](https://supabase.com) — the open-source Firebase alternative (Postgres, Auth, Storage, Realtime, Studio).

**Made by:** Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)

---

## 🛠 Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/supabase/supabase-ubuntu.sh
chmod +x supabase-ubuntu.sh
sudo bash supabase-ubuntu.sh
```

## 🔑 Credentials

| Field | Value |
|-------|-------|
| Studio login | `supabase` / auto-generated (shown at install) |
| anon / service_role keys | Auto-generated JWTs (shown at install) |
| Postgres password | Auto-generated (shown at install) |

## 🌐 Ports

| Port | Purpose |
|------|---------|
| `8200` | Kong API gateway + Studio |

## 💻 Connect

```bash
http://SERVER_IP:8200
```

## 📝 Notes

- Runs the official `supabase/docker` compose stack (~12 containers, 4 GB+ RAM).
- All secrets are generated fresh and written to `/root/docker/supabase/.env`.

---
**Made by Mohammed Ali Elshikh — [prismatechwork.com](https://prismatechwork.com)**
