#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/database_password)

echo "Starting wordpress..."

if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "Missing ENV variables..."
  exit 1
fi

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Initialisation of wordpress volume"
  cp -r /usr/src/wordpress/* /var/www/html
fi

until mariadb -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --ssl=OFF -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for MariaDB"
  sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Creating wp-config.php"
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
  sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
  sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php
  sed -i "s/localhost/$DB_HOST/" /var/www/html/wp-config.php
fi

exec php-fpm82 -F
