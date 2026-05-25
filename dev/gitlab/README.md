# GitLab CE

Complete DevOps platform in one container — Git hosting, CI/CD pipelines, container registry, issue tracker, and merge requests.

## Usage

```bash
wget https://raw.githubusercontent.com/mhmdali94/Docker/main/dev/gitlab/gitlab-ubuntu.sh
chmod +x gitlab-ubuntu.sh
sudo bash gitlab-ubuntu.sh
```

## What It Installs

- **GitLab Community Edition** — Full DevOps platform (Git + CI/CD + Registry + Issues)

## Ports

| Port | Service |
| --- | --- |
| 9080 | Web interface (HTTP) |
| 9443 | Web interface (HTTPS) |
| 2222 | SSH for git clone/push |

## Access

| | URL |
| --- | --- |
| GitLab | `http://<server-ip>:9080` |

## Default Credentials

| Field | Value |
| --- | --- |
| Username | `root` |
| Password | Generated during install (shown at end) |

Change the root password immediately after first login.

## Git Clone via SSH

```bash
# Set port 2222 in SSH config
git clone ssh://git@<server-ip>:2222/username/repo.git

# Or use HTTP
git clone http://<server-ip>:9080/username/repo.git
```

## Requirements

- **Minimum 4 GB RAM** — GitLab will not perform well with less
- **8 GB RAM recommended** for a team environment
- First startup takes 3–5 minutes

## Notes

- CI/CD runners must be registered separately (`gitlab-runner register`)
- Container registry available at port 5005 (not exposed by default)
- Enable SMTP in `./config/gitlab.rb` for email notifications
- Upgrade by pulling the new image: `docker compose pull && docker compose up -d`
