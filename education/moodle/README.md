# Moodle

The world's most popular open-source Learning Management System. Create online courses, quizzes, assignments, and certificates — used by universities, schools, and businesses globally.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/education/moodle/moodle-ubuntu.sh
chmod +x moodle-ubuntu.sh
sudo bash moodle-ubuntu.sh
```

## What It Installs

- **Moodle** — Learning Management System
- **MariaDB 10.11** — Database

## Ports

| Port | Service |
| --- | --- |
| 8083 | Moodle web UI |

## Access

| | URL |
| --- | --- |
| Web UI | `http://<server-ip>:8083` |

## Default Credentials

| Field | Value |
| --- | --- |
| Username | Set during install |
| Password | Generated during install (shown at end) |

## Features

- Course creation with lessons, quizzes, assignments, and forums
- Student enrollment and progress tracking
- Automated grading with gradebook
- SCORM and xAPI content support
- Video, audio, and document embedding
- Certificates and badges on completion
- 1000+ plugins in the Moodle plugin directory
- Mobile app for iOS and Android

## Notes

- Course files and uploads stored in `./moodledata/`
- MariaDB data in `./mariadb/`
- First startup takes 3–5 minutes for installation
- Recommended: 2 GB+ RAM, SSD storage for large student counts
