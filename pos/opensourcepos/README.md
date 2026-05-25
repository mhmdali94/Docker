# Open Source POS

Web-based Point of Sale system for retail shops. Manage products, customers, sales, inventory, and generate reports — all from a browser.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/pos/opensourcepos/opensourcepos-ubuntu.sh
chmod +x opensourcepos-ubuntu.sh
sudo bash opensourcepos-ubuntu.sh
```

## What It Installs

- **Open Source POS** — Point of Sale web application
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 8888 | Open Source POS |

## Access

| | URL |
| --- | --- |
| POS | `http://<server-ip>:8888` |

## Default Credentials

| Field | Value |
| --- | --- |
| Username | `admin` |
| Password | `pointofsale` |

**Change the password immediately after first login.**

## Features

- Product catalog with categories, barcodes, and images
- Customer management and loyalty programs
- Sales and returns processing
- Inventory tracking with stock alerts
- Reports: sales, inventory, profit/loss, taxes
- Multi-user with role-based access
- Receipt printing (thermal printer support)
- Multiple payment methods (cash, card, gift cards)

## Notes

- MySQL data stored in `./mysql/`
- Supports barcode scanning via USB barcode readers
- Tax configuration under **Settings → Taxes**
- Multi-location support available
