# Shlink

Self-hosted URL shortener with analytics. Create short links, track clicks, referrers, countries, and devices — all on your own server with no third-party tracking.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/shlink/shlink-ubuntu.sh
chmod +x shlink-ubuntu.sh
sudo bash shlink-ubuntu.sh
```

## What It Installs

- **Shlink** — URL shortener API
- **Shlink Web Client** — Dashboard UI
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 8585 | Shlink API |
| 8586 | Shlink Web Dashboard |

## Access

| | URL |
| --- | --- |
| API | `http://<server-ip>:8585` |
| Dashboard | `http://<server-ip>:8586` |

## Connecting Dashboard to API

1. Open the dashboard at port 8586
2. Click **Add server**
3. Enter your API URL: `http://<server-ip>:8585`
4. Enter your API key (shown at end of install)

## Creating Short URLs

```bash
# Via API
curl -X POST http://localhost:8585/rest/v3/short-urls \
  -H "X-Api-Key: <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{"longUrl":"https://example.com/very/long/url"}'
```

## Notes

- PostgreSQL data in `./postgres/`
- Tracks clicks, referrers, user agents, and geolocation
- Supports custom slugs, QR codes, and link expiration
- REST API + optional GraphQL endpoint
