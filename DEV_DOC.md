# Developer Documentation

## Environment Setup

**Prerequisites:**
- Linux VM (Ubuntu 22.04+/Debian 11+)
- Docker Engine 20.10+
- Docker Compose 2.0+

**Installation:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose-plugin

# Create directories
sudo mkdir -p /home/$(whoami)/data/{database,site}
```

**Configuration:**

Create `srcs/.env`:
```
DOMAIN_NAME=scambier.42.fr
DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb
DB_PORT=3306
WP_ADMIN_USER=site_admin
WP_ADMIN_EMAIL=admin@example.com
WP_USER_USER=regular_user
WP_USER_EMAIL=user@example.com
```

Create secrets:
```bash
echo "password123" > secrets/database_password.txt
echo "password123" > secrets/database_root_password.txt
echo "password123" > secrets/wordpress_admin_password.txt
echo "password123" > secrets/wordpress_user_password.txt
chmod 600 secrets/*.txt
```

## Building and Launching

**Makefile commands:**
```bash
make          # Build and start
make down     # Stop
make clean    # Stop and remove volumes
make fclean   # Full cleanup
make re       # Rebuild
```

**Manual Docker Compose:**
```bash
sudo docker compose -f srcs/docker-compose.yml build
sudo docker compose -f srcs/docker-compose.yml up -d
sudo docker compose -f srcs/docker-compose.yml logs -f
sudo docker compose -f srcs/docker-compose.yml down
```

## Managing Containers and Volumes

**Containers:**
```bash
sudo docker ps                                    # List running
sudo docker exec -it mariadb sh                   # Shell access
sudo docker logs mariadb                          # View logs
sudo docker restart mariadb                       # Restart
```

**Volumes:**
```bash
sudo docker volume ls                             # List volumes
ls -la /home/scambier/data/database/              # View data
ls -la /home/scambier/data/site/                  # View WordPress files
```

**Network:**
```bash
sudo docker network ls                            # List networks
sudo docker network inspect srcs_local_network    # Details
```

## Data Persistence

**Storage locations:**
- Database: `/home/scambier/data/database/` (MariaDB files)
- WordPress: `/home/scambier/data/site/` (WordPress files)

**First run:** Volumes created, MariaDB initializes, WordPress downloads and installs
**Subsequent runs:** Existing data mounted, services start normally
**Cleanup:** `make clean` deletes data, `make down` preserves it

## Development Workflow

**Modify a service:**
1. Edit files in `srcs/requirements/<service>/`
2. Rebuild: `sudo docker compose -f srcs/docker-compose.yml build --no-cache <service>`
3. Restart: `sudo docker compose -f srcs/docker-compose.yml up -d --force-recreate <service>`
4. Check logs: `sudo docker logs -f <service>`

**Debugging:**
```bash
# View logs
sudo docker compose -f srcs/docker-compose.yml logs -f

# Access container shell
sudo docker exec -it wordpress sh

# Test database connection
sudo docker exec wordpress mariadb -h mariadb -u wpuser -p... -e "SELECT 1;"
```
