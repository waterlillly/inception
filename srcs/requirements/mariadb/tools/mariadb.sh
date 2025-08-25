#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
set -e

# Read secrets from Docker secret files
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

MYSQL_DATA_DIR="/var/lib/mysql"
INIT_SQL="/var/lib/mysql/init.sql"
MYSQL_USER="mysql"

# Validate required environment variables
if [[ -z "${DB_NAME}" || -z "${DB_USER}" || -z "${DB_PASSWORD}" || -z "${DB_ROOT_PASSWORD}" ]]; then
    echo "Error: Missing required environment variables"
    exit 1
fi

# Create init.sql file with proper security
cat > "${INIT_SQL}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

# Initialize MariaDB database if not already initialized
if [ ! -d "${MYSQL_DATA_DIR}/mysql" ]; then
	mysql_install_db --user="${MYSQL_USER}" --datadir="${MYSQL_DATA_DIR}" --skip-test-db
fi

# Start MySQL server with init file
exec mysqld --user="${MYSQL_USER}" --init-file="${INIT_SQL}"