#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/database_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/database_root_password)
DB_ADMIN_PASSWORD=$(cat /run/secrets/database_admin_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initialisation of MariaDB database"

  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  mysqld --user=mysql --skip-networking &
  pid="$!"

  sleep 5

  mysql -u root << EOF
	CREATE DATABASE IF NOT EXISTS ${DB_NAME};

	CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

	CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'%' IDENTIFIED BY '${DB_ADMIN_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_ADMIN}'@'%';

	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

	FLUSH PRIVILEGES;
EOF

  echo "Database initialized"
  kill "$pid"
  wait "$pid"
fi

echo "Starting MariaDB"
exec mysqld --user=mysql

