# Developer Documentation

This document provides technical information for developers working on the Inception project, including setup, architecture, and development workflows.

## Environment Setup from Scratch

### Prerequisites

Before starting, ensure your system has:

1. **Linux Virtual Machine** (Ubuntu 22.04+ or Debian 11+ recommended)
   - Minimum 2GB RAM
   - 20GB free disk space
   - sudo privileges

2. **Docker Engine** (version 20.10+)
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   
   # Verify installation
   docker --version
   ```

3. **Docker Compose** (version 2.0+)
   ```bash
   # Usually included with Docker Desktop
   # Or install standalone:
   sudo apt update
   sudo apt install docker-compose-plugin
   
   # Verify installation
   docker compose version
   ```

4. **Make** utility
   ```bash
   sudo apt install make
   ```

### Project Structure Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Create required directories:**
   ```bash
   # Create data directories on host
   sudo mkdir -p /home/$(whoami)/data/database
   sudo mkdir -p /home/$(whoami)/data/site
   
   # Set proper permissions
   sudo chown -R $(whoami):$(whoami) /home/$(whoami)/data
   sudo chmod 755 /home/$(whoami)/data/database
   sudo chmod 755 /home/$(whoami)/data/site
   ```

   **Note**: If your username is different from `scambier`, update the paths in `docker-compose.yml`:
   ```yaml
   volumes:
     database:
       driver_opts:
         device: /home/YOUR_USERNAME/data/database
     site:
       driver_opts:
         device: /home/YOUR_USERNAME/data/site
   ```

3. **Configure secrets:**
   
   Create password files in `secrets/` directory:
   ```bash
   # Generate secure passwords (or use your own)
   openssl rand -base64 32 > secrets/database_password.txt
   openssl rand -base64 32 > secrets/database_root_password.txt
   openssl rand -base64 32 > secrets/wordpress_admin_password.txt
   openssl rand -base64 32 > secrets/wordpress_user_password.txt
   
   # Secure the files
   chmod 600 secrets/*.txt
   ```

4. **Create environment configuration:**
   
   Create `srcs/.env` file:
   ```bash
   cat > srcs/.env << 'EOF'
   # Domain Configuration
   DOMAIN_NAME=scambier.42.fr
   
   # Database Configuration
   DB_NAME=wordpress
   DB_USER=wpuser
   DB_HOST=mariadb
   DB_PORT=3306
   
   # WordPress Admin User (cannot contain 'admin' or 'administrator')
   WP_ADMIN_USER=site_administrator
   WP_ADMIN_EMAIL=admin@scambier.42.fr
   
   # WordPress Regular User
   WP_USER_USER=regular_user
   WP_USER_EMAIL=user@scambier.42.fr
   EOF
   ```

   **Important**: The admin username must NOT contain "admin" or "administrator" (project requirement).

5. **Generate SSL certificates (already included):**
   
   If you need to regenerate:
   ```bash
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout srcs/requirements/nginx/certs/selfsigned.key \
     -out srcs/requirements/nginx/certs/selfsigned.crt \
     -subj "/C=FR/ST=Paris/L=Paris/O=42/CN=scambier.42.fr"
   ```

## Building and Launching the Project

### Using the Makefile

The Makefile provides convenient commands for managing the infrastructure:

```bash
# Build and start everything
make

# Stop containers (preserve data)
make down

# Stop and remove volumes
make clean

# Full cleanup (remove images, cache, etc.)
make fclean

# Clean site files only
make rmsite

# Clean database files only
make rmdatabase

# Full rebuild
make re
```

### Manual Docker Compose Commands

For finer control:

```bash
# Build images
sudo docker compose -f srcs/docker-compose.yml build

# Start services
sudo docker compose -f srcs/docker-compose.yml up -d

# View logs
sudo docker compose -f srcs/docker-compose.yml logs -f

# Stop services
sudo docker compose -f srcs/docker-compose.yml down

# Stop and remove volumes
sudo docker compose -f srcs/docker-compose.yml down -v

# Rebuild specific service
sudo docker compose -f srcs/docker-compose.yml build --no-cache mariadb
sudo docker compose -f srcs/docker-compose.yml up -d mariadb
```

### Build Process Explained

When running `make`:

1. **set_domain_name.sh** adds `127.0.0.1 scambier.42.fr` to `/etc/hosts`
2. **Docker Compose** reads `docker-compose.yml` and `.env`
3. **Images are built** from Dockerfiles:
   - MariaDB: Alpine + MariaDB server
   - WordPress: Alpine + PHP-FPM + WP-CLI
   - NGINX: Alpine + NGINX + SSL certificates
4. **Volumes are created** and mounted to host directories
5. **Network is created** (bridge mode)
6. **Secrets are mounted** as read-only files in containers
7. **Containers start** in dependency order: MariaDB → WordPress → NGINX
8. **Init scripts run**:
   - MariaDB: Initialize database, create users
   - WordPress: Download WordPress, configure, install, create users

## Managing Containers and Volumes

### Container Management

**List running containers:**
```bash
sudo docker ps
```

**List all containers (including stopped):**
```bash
sudo docker ps -a
```

**View container details:**
```bash
sudo docker inspect mariadb
sudo docker inspect wordpress
sudo docker inspect nginx
```

**Execute commands in containers:**
```bash
# Interactive shell
sudo docker exec -it mariadb sh
sudo docker exec -it wordpress sh
sudo docker exec -it nginx sh

# Single command
sudo docker exec mariadb mysql -u root -p$(cat secrets/database_root_password.txt) -e "SHOW DATABASES;"
sudo docker exec wordpress wp --info --allow-root
```

**Restart containers:**
```bash
sudo docker restart mariadb
sudo docker restart wordpress
sudo docker restart nginx

# Or restart all
sudo docker compose -f srcs/docker-compose.yml restart
```

**View resource usage:**
```bash
sudo docker stats
```

### Volume Management

**List volumes:**
```bash
sudo docker volume ls
```

**Inspect volume:**
```bash
sudo docker volume inspect srcs_database
sudo docker volume inspect srcs_site
```

**Check volume contents:**
```bash
# Database volume
ls -la /home/scambier/data/database/

# Site volume
ls -la /home/scambier/data/site/
```

## Data Persistence

### Where Data is Stored

The project uses Docker volumes with bind mounts to persist data on the host:

**Database Data:**
- Volume name: `srcs_database`
- Host location: `/home/scambier/data/database/`
- Contains: MariaDB database files, system tables, WordPress data

**WordPress Files:**
- Volume name: `srcs_site`
- Host location: `/home/scambier/data/site/`
- Contains: WordPress core files, themes, plugins, uploads, wp-config.php

### Data Lifecycle

**First Run:**
1. Volumes are created and mounted
2. MariaDB initializes database structure in `/var/lib/mysql/`
3. WordPress downloads and extracts to `/var/www/html/`
4. wp-config.php is created with database credentials
5. WordPress installation runs (creates tables, admin user)
6. Regular user is created

**Subsequent Runs:**
1. Volumes mount existing data
2. MariaDB starts with existing databases
3. WordPress detects existing installation (skips setup)
4. Services start normally

**Data Preservation:**
- `make down`: Data preserved, containers stopped
- `make clean`: Data deleted, fresh start needed
- `make fclean`: Complete cleanup including Docker system

### Accessing Persisted Data

**Direct filesystem access:**
```bash
# View database files
sudo ls -la /home/scambier/data/database/wordpress/

# View WordPress files
sudo ls -la /home/scambier/data/site/

# Edit WordPress configuration
sudo nano /home/scambier/data/site/wp-config.php
```

**Access via container:**
```bash
# Database operations
sudo docker exec -it mariadb mysql -u root -p

# WordPress CLI operations
sudo docker exec -it wordpress wp --allow-root post list
sudo docker exec -it wordpress wp --allow-root plugin list
```

## Architecture Details

### Container Specifications

**NGINX Container:**
- Base: `alpine:3.19`
- Exposed: Port 443 (HTTPS)
- Volumes: `/var/www/html` (read-only) mounted from `site` volume
- Configuration: `/etc/nginx/http.d/default.conf`
- Certificates: `/etc/ssl/certs/selfsigned.{crt,key}`
- Role: Reverse proxy, handles TLS, serves static files, forwards PHP to WordPress

**WordPress Container:**
- Base: `alpine:3.19`
- Packages: PHP 8.2, PHP-FPM, WP-CLI, MariaDB client
- Exposed: Port 9000 (PHP-FPM, internal only)
- Volumes: `/var/www/html` mounted from `site` volume
- Configuration: `/etc/php82/php-fpm.d/www.conf`
- Role: Process PHP, run WordPress, communicate with database

**MariaDB Container:**
- Base: `alpine:3.19`
- Packages: MariaDB server and client
- Exposed: Port 3308 (internal only)
- Volumes: `/var/lib/mysql` mounted from `database` volume
- Configuration: `/etc/my.cnf` (50-server.cnf)
- Role: Store and manage WordPress data

### Initialization Scripts

**MariaDB Init (`requirements/mariadb/tools/init.sh`):**
1. Creates `/run/mysqld` directory for socket
2. Checks if database exists
3. If first run:
   - Initializes MariaDB data directory
   - Starts temporary server (no networking)
   - Creates WordPress database
   - Creates WordPress user with privileges
   - Sets root password
   - Shuts down temporary server
4. Starts MariaDB server permanently

**WordPress Init (`requirements/wordpress/tools/init.sh`):**
1. Validates environment variables
2. Waits for MariaDB to be ready
3. Copies WordPress files from `/usr/src/wordpress/` to `/var/www/html/`
4. Creates `wp-config.php` using WP-CLI
5. Runs WordPress installation if not already installed
6. Creates regular user account if doesn't exist
7. Starts PHP-FPM server

### Security Implementations

**TLS/SSL:**
- NGINX configured for TLS 1.2 and 1.3 only
- Self-signed certificate (replace with valid cert for production)
- HTTPS-only (no HTTP port 80)

**Secrets Management:**
- Passwords stored in separate files under `secrets/`
- Mounted as read-only into containers at `/run/secrets/`
- Not visible in environment variables or container inspection
- Proper file permissions (600) recommended

**Network Isolation:**
- Custom bridge network isolates containers
- MariaDB not exposed to host network
- WordPress not exposed to host network
- Only NGINX exposes port 443

**User Permissions:**
- PHP-FPM runs as `nobody:nobody` (non-root)
- MariaDB runs as `mysql:mysql` (non-root)
- NGINX runs as `nginx:nginx` (non-root)

## Development Workflow

### Making Changes

**To modify a service:**

1. Edit the relevant files:
   - Dockerfile: `srcs/requirements/<service>/Dockerfile`
   - Configuration: `srcs/requirements/<service>/conf/`
   - Init script: `srcs/requirements/<service>/tools/init.sh`

2. Rebuild the specific service:
   ```bash
   sudo docker compose -f srcs/docker-compose.yml build --no-cache <service>
   ```

3. Recreate the container:
   ```bash
   sudo docker compose -f srcs/docker-compose.yml up -d --force-recreate <service>
   ```

4. Check logs:
   ```bash
   sudo docker compose -f srcs/docker-compose.yml logs -f <service>
   ```

### Testing Changes

**Test database connectivity:**
```bash
sudo docker exec wordpress mariadb -h mariadb -u wpuser -p$(cat secrets/database_password.txt) -e "SELECT 1;"
```

**Test NGINX configuration:**
```bash
sudo docker exec nginx nginx -t
```

**Test PHP-FPM:**
```bash
sudo docker exec wordpress php-fpm82 -t
```

**Test WordPress installation:**
```bash
sudo docker exec wordpress wp --allow-root core is-installed && echo "Installed" || echo "Not installed"
```

### Debugging

**Monitor real-time logs:**
```bash
# All services
sudo docker compose -f srcs/docker-compose.yml logs -f

# Specific service
sudo docker logs -f wordpress
```

**Inspect container environment:**
```bash
sudo docker exec wordpress env
sudo docker exec mariadb env
```

## Common Development Tasks

### Update WordPress Version

1. Edit `requirements/wordpress/Dockerfile`:
   ```dockerfile
   # Change latest.tar.gz to specific version
   RUN wget https://wordpress.org/wordpress-6.4.tar.gz
   ```

2. Rebuild:
   ```bash
   make down
   make rmsite
   sudo docker compose -f srcs/docker-compose.yml build --no-cache wordpress
   make
   ```

### Change PHP Version

1. Update `requirements/wordpress/Dockerfile`:
   ```dockerfile
   RUN apk add --no-cache \
       php83 \
       php83-fpm \
       # ... update all php82 to php83
   ```

2. Update init script and config file references
3. Rebuild WordPress container

### Add New Environment Variable

1. Add to `srcs/.env`:
   ```
   NEW_VARIABLE=value
   ```

2. Update `docker-compose.yml` if needed:
   ```yaml
   wordpress:
     env_file:
       - .env
   ```

3. Use in scripts:
   ```bash
   echo "Value: $NEW_VARIABLE"
   ```

## Troubleshooting for Developers

### Container Won't Start

1. Check logs: `sudo docker logs <container>`
2. Check init script for errors
3. Verify dependencies are met (e.g., MariaDB before WordPress)
4. Test Dockerfile builds: `sudo docker build -t test srcs/requirements/<service>/`

### Database Won't Initialize

1. Check MariaDB logs: `sudo docker logs mariadb`
2. Verify secrets are readable: `cat secrets/database_password.txt`
3. Remove database and retry:
   ```bash
   make down
   make rmdatabase
   make
   ```

### WordPress Installation Fails

1. Ensure MariaDB is fully started before WordPress
2. Check database connection: `sudo docker exec wordpress mariadb -h mariadb -u wpuser -p... -e "SELECT 1;"`
3. Verify WP-CLI works: `sudo docker exec wordpress wp --info --allow-root`
4. Check init script logs for errors

## Best Practices

1. **Always test locally** before committing
2. **Use `--no-cache`** when rebuilding after Dockerfile changes
3. **Check logs** after every change
4. **Backup data** before major changes
5. **Version control** `.env.example` but not `.env`
6. **Document** any non-obvious configuration choices
7. **Use secrets** for all sensitive data
8. **Validate** Docker Compose file: `docker compose -f srcs/docker-compose.yml config`

