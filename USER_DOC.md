# User Documentation

## Services Provided

- **WordPress**: Content management system at `https://scambier.42.fr`
- **NGINX**: Web server with TLS 1.2/1.3 encryption
- **MariaDB**: Database (internal only)

Data persists in `/home/scambier/data/`

## Starting and Stopping

**Start:**
```bash
make
```

**Stop:**
```bash
make down
```

**Check status:**
```bash
sudo docker ps
```

## Accessing the Website

**Main site:** `https://scambier.42.fr`
**Admin panel:** `https://scambier.42.fr/wp-admin`

Accept the self-signed certificate warning in your browser.

## Credentials

Passwords are in `secrets/` directory:
- `database_password.txt`
- `database_root_password.txt`
- `wordpress_admin_password.txt`
- `wordpress_user_password.txt`

Usernames are defined in `srcs/.env`:
- `WP_ADMIN_USER` (administrator)
- `WP_USER_USER` (author)

## Checking Services

**Status:**
```bash
sudo docker ps
```

**Logs:**
```bash
sudo docker compose -f srcs/docker-compose.yml logs
```

**Test connectivity:**
```bash
curl -k https://scambier.42.fr
```
