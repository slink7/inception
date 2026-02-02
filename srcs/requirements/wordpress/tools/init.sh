#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/database_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)

echo "Starting wordpress..."

if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "Missing ENV variables..."
  exit 1
fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
  echo "Initialisation of wordpress volume"
  cp -r /usr/src/wordpress/* .
fi

until mariadb -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --ssl=OFF -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for MariaDB"
  sleep 2
done

if [ ! -f wp-config.php ]; then
  echo "Creating wp-config.php"
  wp config create \
	  --dbhost=$DB_HOST\
	  --dbname=$DB_NAME\
	  --dbuser=$DB_USER\
	  --dbpass=$DB_PASSWORD\
	  --allow-root
fi

if ! wp core is-installed --allow-root; then
	echo "Installing using wp-cli"
	wp core install\
		--url="https://$DOMAIN_NAME"\
		--title="Inception supersite"\
		--admin_user="$WP_ADMIN_USER"\
		--admin_password="$WP_ADMIN_PASSWORD"\
		--admin_email="$WP_ADMIN_EMAIL"\
		--skip-email\
		--allow-root
fi

if ! wp user get "$WP_USER_USER" --allow-root >/dev/null 2>&1; then
	echo "Creating normal user"
	wp user create "$WP_USER_USER" "$WP_USER_EMAIL"\
		--user_pass="$WP_USER_PASSWORD"\
		--role=author\
		--allow-root
fi

exec php-fpm82 -F
