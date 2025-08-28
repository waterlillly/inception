#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
# although mostly already handled by me (error logs and exiting)
set -e

# Read secrets from Docker secret files
DB_USER_PASS="$(cat /run/secrets/db_user_password)"
DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"

# Validate required variables
: "${DB_NAME:?[ERROR] DB_NAME not set}"
: "${DB_USER:?[ERROR] DB_USER not set}"
: "${DB_DATA_DIR:?[ERROR] DB_DATA_DIR not set}"
: "${DB_USER_PASS:?[ERROR] DB_USER_PASS not set}"
: "${DB_ROOT_PASS:?[ERROR] DB_ROOT_PASS not set}"

# Initialize MariaDB database if not already initialized
# -d checks if a directory exists at the specified path
if [ ! -d "${DB_DATA_DIR}/mysql" ]; then
    echo "[INFO] Initializing MariaDB data directory.."
	mariadb_install_db --user=mysql --datadir="${DB_DATA_DIR}" --skip-test-db || { echo "[ERROR] MariaDB installation failed"; exit 1; }
fi

# Create init.sql
cat > "${DB_DATA_DIR}/init.sql" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

# Start MariaDB (by default in foreground)
echo "[INFO] Starting MariaDB.."
exec mariadbd --user=mysql --datadir="${DB_DATA_DIR}" --init-file="${DB_DATA_DIR}/init.sql"