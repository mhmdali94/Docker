# Medusa

Open-source composable commerce platform. Headless e-commerce backend with a React admin dashboard, REST API, and support for multi-region, multi-currency stores.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/medusa/medusa-ubuntu.sh
chmod +x medusa-ubuntu.sh
sudo bash medusa-ubuntu.sh
```

## What It Installs

- **Medusa** — Commerce backend + admin dashboard
- **PostgreSQL 15** — Database
- **Redis 7** — Cache and queues

## Ports

| Port | Service |
| --- | --- |
| 9000 | Backend API |
| 7001 | Admin dashboard |

## Access

| | URL |
| --- | --- |
| API | `http://<server-ip>:9000` |
| Admin | `http://<server-ip>:7001` |
| API docs | `http://<server-ip>:9000/api` |

## Default Credentials

Create an admin user after startup:
```bash
docker exec medusa medusa user -e admin@example.com -p yourpassword
```

## Notes

- First start takes ~90 seconds to run database migrations
- Build a custom storefront with Next.js/Nuxt and point it at the API
- Supports Stripe, PayPal, Klarna payments via plugins
- Multi-region pricing, tax, and currency management built-in
- PostgreSQL data in `./postgres/`, Redis data in `./redis/`
