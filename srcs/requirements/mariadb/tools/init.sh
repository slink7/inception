#!/bin/sh
set -e

# Créer le dossier du socket MySQL
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialisation si la base n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "🟡 Initialisation de MariaDB..."

  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
  pid="$!"

  sleep 5

  mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS inception_db;
CREATE USER IF NOT EXISTS 'inception_user'@'%' IDENTIFIED BY 'inception_pwd';
GRANT ALL PRIVILEGES ON inception_db.* TO 'inception_user'@'%';
FLUSH PRIVILEGES;
EOF

  echo "🟢 Base initialisée"
  kill "$pid"
  wait "$pid"
fi

echo "🚀 Lancement MariaDB"
#exec mariadbd --user=mysql
exec mysqld --user=mysql

