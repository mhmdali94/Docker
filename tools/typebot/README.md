# Typebot

Visual chatbot and form builder — embed conversational flows on any website without code.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/tools/typebot/typebot-ubuntu.sh
chmod +x typebot-ubuntu.sh
sudo bash typebot-ubuntu.sh
```

## What It Installs

- **Typebot Builder** — visual flow editor
- **Typebot Viewer** — runtime that serves bots to end users
- **PostgreSQL** — primary database

## Credentials

| Field | Value |
| --- | --- |
| Builder URL | http://\<server-ip\>:3310 |
| Viewer URL | http://\<server-ip\>:3311 |
| Setup | Register on first visit |

## Ports

| Port | Service |
| --- | --- |
| 3310 | Typebot Builder |
| 3311 | Typebot Viewer |

## Connect

Open the builder at `http://<server-ip>:3310` and register. Design your bot flow, then publish — the viewer at port 3311 serves it to end users. Use the embed snippet to add the bot to any webpage.
