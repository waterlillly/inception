#!/bin/bash

set -e

# read secrets
DB_USER_PASS="$(cat /run/secrets/db_user_password)"
DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"

# validate required vars
: "${DB_NAME:?[ERROR] DB_NAME not set}"
: "${DB_USER:?[ERROR] DB_USER not set}"
: "${DB_USER_PASS:?[ERROR] DB_USER_PASS not set}"
: "${DB_ROOT_PASS:?[ERROR] DB_ROOT_PASS not set}"

# -d -> check if directory exists at this path
# --skip-test-db -> normally created by default
# 		=> better security (test-db is often used during attacks)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[INFO] Initializing MariaDB.."
	mariadb-install-db --datadir="/var/lib/mysql" --skip-test-db \
	|| { echo "[ERROR] MariaDB installation failed"; exit 1; }
fi

# create init.sql
# backticks [`] around ${DB_NAME} to allow special characters (like -) in DB name
# CREATE/GRANT auto-flush (INSERT/UPDATE/DELETE/etc. don't => FLUSH PRIVILEGES needed)
cat > "/var/lib/mysql/init.sql" <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
EOF

# runs by default in foreground
echo "[INFO] Starting MariaDB.."
exec mariadbd --datadir="/var/lib/mysql" --init-file="/var/lib/mysql/init.sql"