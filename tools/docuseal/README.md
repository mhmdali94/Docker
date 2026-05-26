# DocuSeal

Open-source document signing platform. Create PDF forms, collect legally binding e-signatures, and manage signing workflows — self-hosted DocuSign alternative.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/docuseal/docuseal-ubuntu.sh
chmod +x docuseal-ubuntu.sh
sudo bash docuseal-ubuntu.sh
```

## What It Installs

- **DocuSeal** — Document e-signing platform (SQLite built-in)

## Ports

| Port | Service |
| --- | --- |
| 3008 | DocuSeal web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:3008` |

## Default Credentials

None — the first visit creates your admin account.

## Features

- Upload PDF templates and add signature/text/date fields visually
- Send signing requests via email with unique links
- Signers don't need an account — sign directly from the email link
- Audit trail with timestamps and IP addresses
- Multiple signers per document with defined order
- REST API for automation and integration

## Notes

- All data stored in `./data/` using SQLite
- Documents and signatures stored locally — no cloud upload
- SMTP email configuration available in Settings for sending signing requests
