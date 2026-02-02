# Inception

*This project has been created as part of the 42 curriculum by scambier.*

## Description

Infrastructure setup using Docker Compose with three services: NGINX (reverse proxy with TLS), WordPress with PHP-FPM, and MariaDB database. Services run in separate containers with persistent volumes and communicate through a Docker network.

## Instructions

**Prerequisites:**
- Linux VM
- Docker Engine and Docker Compose

**Setup:**
```bash
sudo mkdir -p /home/scambier/data/{database,site}
```

Create `srcs/.env`:
```
DOMAIN_NAME=scambier.42.fr
DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb
DB_PORT=3306
WP_ADMIN_USER=admin_user
WP_ADMIN_EMAIL=admin@example.com
WP_USER_USER=regular_user
WP_USER_EMAIL=user@example.com
```

**Run:**
```bash
make
```

Access: `https://scambier.42.fr`

## Project Architecture

### Virtual Machines vs Docker

VMs virtualize hardware with full OS isolation, requiring significant resources. Docker containers share the host kernel, providing lightweight process isolation with minimal overhead. Docker is more efficient for this multi-service architecture.

### Secrets vs Environment Variables

Environment variables (.env): Non-sensitive configuration (domain names, usernames)
Docker secrets (secrets/): Sensitive data (passwords) mounted as read-only files in /run/secrets/

This project uses both for proper separation of configuration and credentials.

### Docker Network vs Host Network

Host network: Container shares host network stack, no isolation
Docker network (bridge): Isolated network namespace with internal DNS

This project uses a custom bridge network for service isolation while enabling internal communication.

### Docker Volumes vs Bind Mounts

Bind mounts: Direct host path mapping
Docker volumes: Docker-managed storage

This project uses named volumes with bind mount options to persist data in /home/scambier/data/ while maintaining Docker volume management.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress](https://wordpress.org/support/)
- [WP-CLI](https://wp-cli.org/)

### AI Usage

AI was used for:
- Dockerfile syntax and structure
- Docker Compose configuration
- Shell script debugging
- Configuration file syntax
- Researching best practices (TLS, security, PHP-FPM)

All generated content was reviewed and tested for full understanding.
