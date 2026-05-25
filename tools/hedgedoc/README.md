# HedgeDoc

Real-time collaborative Markdown editor. Multiple people can edit the same document simultaneously — like Google Docs but for Markdown, self-hosted.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/hedgedoc/hedgedoc-ubuntu.sh
chmod +x hedgedoc-ubuntu.sh
sudo bash hedgedoc-ubuntu.sh
```

## What It Installs

- **HedgeDoc** — Collaborative Markdown editor
- **PostgreSQL 15** — Database

## Ports

| Port | Service |
| --- | --- |
| 3888 | HedgeDoc web interface |

## Access

| | URL |
| --- | --- |
| Dashboard | `http://<server-ip>:3888` |
| New note | `http://<server-ip>:3888/new` |

## Default Credentials

Anonymous access is enabled by default. Set up authentication in `docker-compose.yml` by configuring an OAuth provider (GitHub, GitLab, Google, etc.).

## Notes

- Uploaded images stored in `./uploads/`
- Supports Markdown, MathJax, Mermaid diagrams, code highlighting
- Each note gets a unique shareable URL
- Real-time collaboration with presence cursors
- Export to PDF, HTML, or raw Markdown
