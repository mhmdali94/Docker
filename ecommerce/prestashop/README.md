# PrestaShop

Full-featured open-source e-commerce platform. Product catalog, orders, customers, payments, shipping, and multi-language/multi-currency support out of the box.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/ecommerce/prestashop/prestashop-ubuntu.sh
chmod +x prestashop-ubuntu.sh
sudo bash prestashop-ubuntu.sh
```

## What It Installs

- **PrestaShop** — E-commerce platform
- **MySQL 8.0** — Database

## Ports

| Port | Service |
| --- | --- |
| 8020 | PrestaShop store + admin |

## Access

| | URL |
| --- | --- |
| Store | `http://<server-ip>:8020` |
| Admin | `http://<server-ip>:8020/admin_panel` |

## Default Credentials

| Field | Value |
| --- | --- |
| Email | `admin@prestashop.local` |
| Password | Generated during install (shown at end) |

## Notes

- First startup takes 2–4 minutes while PrestaShop installs itself
- Store data in `./data/`, MySQL data in `./mysql/`
- 5000+ free modules and themes available on Addons marketplace
- Supports 75+ payment gateways
- Built-in SEO, multi-store, and loyalty programs
