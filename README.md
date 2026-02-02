# Inception

*This project has been created as part of the 42 curriculum by scambier.*

## Description

Inception is a system administration project focused on Docker containerization and infrastructure orchestration. The goal is to set up a small-scale web infrastructure using Docker Compose, consisting of NGINX, WordPress, and MariaDB services running in separate containers with proper security configurations.

This project demonstrates practical understanding of:
- Docker containerization and multi-container orchestration
- Secure web service configuration (TLS/SSL)
- Database management and persistent storage
- Network isolation and inter-container communication
- Secret management and environment variable usage

The infrastructure serves a WordPress website accessible via HTTPS on the domain `scambier.42.fr`, with all services properly isolated and communicating through a dedicated Docker network.

## Instructions

### Prerequisites

- A Linux virtual machine (Ubuntu/Debian recommended)
- Docker Engine installed
- Docker Compose installed
- sudo privileges
- At least 2GB of free disk space

### Installation & Execution

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Create the required data directories:
```bash
sudo mkdir -p /home/scambier/data/database
sudo mkdir -p /home/scambier/data/site
```

3. Ensure the secrets files contain your passwords (already present in the `secrets/` directory):
   - `database_password.txt`
   - `database_root_password.txt`
   - `wordpress_admin_password.txt`
   - `wordpress_user_password.txt`

4. Create a `.env` file in the `srcs/` directory with your configuration:
```bash
# Example .env file (create at srcs/.env)
DOMAIN_NAME=scambier.42.fr

# Database configuration
DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb
DB_PORT=3306

# WordPress admin user
WP_ADMIN_USER=admin_user
WP_ADMIN_EMAIL=admin@example.com

# WordPress regular user
WP_USER_USER=regular_user
WP_USER_EMAIL=user@example.com
```

5. Build and start the infrastructure:
```bash
make
```

6. Access your WordPress site at: `https://scambier.42.fr`

### Available Make Commands

- `make` or `make all` - Set up domain name and build/start all containers
- `make down` - Stop all containers
- `make clean` - Stop containers and remove volumes
- `make fclean` - Full cleanup including Docker system prune
- `make rmsite` - Remove WordPress site files
- `make rmdatabase` - Remove database files
- `make re` - Full rebuild (fclean + all)

## Project Architecture

### Docker vs Virtual Machines

**Virtual Machines** provide full OS virtualization with complete isolation but come with significant overhead. Each VM runs its own kernel and requires substantial resources.

**Docker containers** share the host OS kernel and provide process-level isolation. They are:
- Lightweight (MB vs GB)
- Fast to start (seconds vs minutes)
- Resource-efficient (minimal overhead)
- Portable across environments
- Ideal for microservices architecture

For this project, Docker is the superior choice as it allows running multiple isolated services (NGINX, WordPress, MariaDB) with minimal resource consumption while maintaining proper separation of concerns.

### Secrets vs Environment Variables

**Environment Variables** (`.env` file):
- Store non-sensitive configuration (domain names, database names, usernames)
- Visible in container inspection and process lists
- Suitable for configuration that may vary between environments
- Easy to override and manage

**Docker Secrets** (`secrets/` directory):
- Store sensitive data (passwords, API keys, certificates)
- Mounted as read-only files in `/run/secrets/`
- Not visible in environment or logs
- Better security through filesystem permissions
- Only accessible to specified services

This project uses both: `.env` for configuration and Docker secrets for all passwords, following security best practices.

### Docker Network vs Host Network

**Host Network**:
- Container shares host's network stack
- No network isolation
- Potential port conflicts
- Security risk (broader attack surface)

**Docker Network** (bridge mode):
- Isolated network namespace
- Internal DNS resolution between containers
- Controlled port exposure
- Better security through isolation
- Easier to manage service communication

This project uses a custom bridge network (`local_network`) to ensure services can communicate internally while remaining isolated from the host network. Only NGINX exposes port 443 to the outside world.

### Docker Volumes vs Bind Mounts

**Bind Mounts**:
- Direct mapping to host filesystem path
- Host-dependent (paths must exist)
- Full host filesystem access
- Difficult to migrate or backup

**Docker Volumes**:
- Managed by Docker
- Portable and platform-independent
- Better performance on non-Linux hosts
- Easier backup and migration
- Proper lifecycle management

This project uses named volumes with bind mount driver options to combine both approaches: Docker manages the volumes while data persists in a specific host location (`/home/scambier/data/`) for easy access and backup.

## Resources

### Docker Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

### Service-Specific Resources
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Installation Guide](https://wordpress.org/support/article/how-to-install-wordpress/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### Security Resources
- [SSL/TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [Docker Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

### AI Usage

AI was used in this project for the following tasks:

**General Information**
- Explanation of what the technologies are
- How they function together
- The differences between them

**Troubleshooting:**
- Help with connecting services together
- Understanding where issues came from
- Solving problems I did not understand

**Documentation:**
- Help with the redaction of the README files
- Explanation of hard to understand docs

*All AI-generated content was reviewed and tested to ensure full understanding and proper functionality within the project context.*

