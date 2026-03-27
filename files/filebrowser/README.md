# FileBrowser

Web-based file manager for your server.

## Quick Install

```bash
wget https://raw.githubusercontent.com/yourusername/docker/main/filebrowser/filebrowser-ubuntu.sh
sudo bash filebrowser-ubuntu.sh
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/docker/main/filebrowser/filebrowser-ubuntu.sh | sudo bash
```

## What is FileBrowser?

FileBrowser provides a simple web interface to manage files on your server. Access your files from any device with a web browser.

## Features

- Browse files and folders
- Upload files (drag & drop support)
- Download files
- Create folders
- Rename and delete files
- Edit text files in browser
- Preview images, videos, documents
- Multi-user support

## Port

| Port | Purpose |
|------|---------|
| 8080 | Web interface |

## Default Credentials

- **Username:** `admin`
- **Password:** `admin`

⚠️ **Change these immediately after login!**

## Accessing FileBrowser

After installation, open:
```
http://SERVER_IP:8080
```

## Directory Structure

```
/root/docker/filebrowser/
├── docker-compose.yml
├── database/      # User database
└── config/        # Configuration files
```

## Browsable Files

By default, FileBrowser is configured to browse `/root` (root home directory).

To browse a different location, edit the volume in `docker-compose.yml`:

```yaml
volumes:
  - /path/to/browse:/srv
```

## Managing Users

After logging in:
1. Click Settings (gear icon)
2. Go to "User Management"
3. Add or edit users

## Use Cases

- Access server files without SSH
- Quick file uploads/downloads
- Share files with team members
- Manage media files
- Edit configuration files

## Security Notes

- Default credentials are `admin/admin` - change immediately
- Run behind Nginx Proxy Manager for HTTPS
- Restrict access with firewall rules if needed

## Documentation

- [FileBrowser GitHub](https://github.com/filebrowser/filebrowser)
- [Official Documentation](https://filebrowser.org/)

## ⚠️ Disclaimer

This script is for **demo/testing purposes only**. Not intended for production use.

## Author

Made by: Mohammed Ali Elshikh | [prismatechwork.com](https://prismatechwork.com)
