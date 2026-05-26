# Meilisearch

Lightning-fast, typo-tolerant search engine. Add full-text search to any app with a simple REST API. Returns results in under 50ms even on millions of documents.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/databases/meilisearch/meilisearch-ubuntu.sh
chmod +x meilisearch-ubuntu.sh
sudo bash meilisearch-ubuntu.sh
```

## What It Installs

- **Meilisearch v1.6** — Search engine

## Ports

| Port | Service |
| --- | --- |
| 7700 | Meilisearch API + UI |

## Access

| | URL |
| --- | --- |
| Web UI (Mini Dashboard) | `http://<server-ip>:7700` |
| API | `http://<server-ip>:7700` |

## Quick Start

```bash
# Create an index
curl -X POST http://localhost:7700/indexes \
  -H "Authorization: Bearer <master-key>" \
  -H "Content-Type: application/json" \
  -d '{"uid":"products","primaryKey":"id"}'

# Add documents
curl -X POST http://localhost:7700/indexes/products/documents \
  -H "Authorization: Bearer <master-key>" \
  -H "Content-Type: application/json" \
  -d '[{"id":1,"name":"Apple iPhone"},{"id":2,"name":"Samsung Galaxy"}]'

# Search
curl "http://localhost:7700/indexes/products/search?q=iphone" \
  -H "Authorization: Bearer <master-key>"
```

## Notes

- Data stored in `./data/`
- Analytics disabled by default for privacy
- SDKs available for JavaScript, Python, PHP, Go, Ruby, Rust, and more
- Supports faceted search, filters, sorting, geosearch, and multi-tenant API keys
