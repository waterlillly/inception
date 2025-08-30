#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
# although mostly already handled by me (error logs and exiting)
set -e

# Read secrets from Docker secret files
DB_USER_PASS="$(cat /run/secrets/db_user_password)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"

# Validate required variables
: "${DOMAIN_NAME:?[ERROR] DOMAIN_NAME not set}"
: "${DB_NAME:?[ERROR] DB_NAME not set}"
: "${DB_DATA_DIR:?[ERROR] DB_DATA_DIR not set}"
: "${DB_USER:?[ERROR] DB_USER not set}"
: "${DB_USER_PASS:?[ERROR] DB_USER_PASS not set}"
: "${WP_TITLE:?[ERROR] WP_TITLE not set}"
: "${WP_ADMIN_USER:?[ERROR] WP_ADMIN_USER not set}"
: "${WP_ADMIN_EMAIL:?[ERROR] WP_ADMIN_EMAIL not set}"
: "${WP_ADMIN_PASS:?[ERROR] WP_ADMIN_PASS not set}"
: "${WP_USER:?[ERROR] WP_USER not set}"
: "${WP_USER_EMAIL:?[ERROR] WP_USER_EMAIL not set}"
: "${WP_USER_PASS:?[ERROR] WP_USER_PASS not set}"

# Set working directory to WordPress root
cd /var/www/html

# Check if WordPress is already downloaded
# -f checks if the file exists (checking for index.php which is part of WordPress core)
if [[ ! -f "index.php" ]]; then
    echo "[INFO] Downloading WordPress..."
    wp core download --allow-root
	if [[ ! -f "index.php" ]]; then
		echo "[ERROR] WordPress could not be downloaded"
		exit 1
	fi
    echo "[INFO] WordPress downloaded successfully"
else
    echo "[INFO] WordPress already downloaded, skipping download"
fi

# Always create/update wp-config.php with current database settings
echo "[INFO] Configuring WordPress..."
wp config create \
	--dbname="${DB_NAME}" \
	--dbuser="${DB_USER}" \
	--dbpass="${DB_USER_PASS}" \
	--dbhost="${DB_HOST}" \
	--allow-root \
	--force || { echo "[ERROR] Failed to create wp-config.php"; exit 1; }

# Utils
create_user() {
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="${WP_USER_PASS}" \
		--allow-root || { echo "[ERROR] Failed to create user ${WP_USER}"; return 1; }
}

install_wordpress() {
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASS}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--theme="twentytwentythree" --activate \
		--allow-root || { echo "[ERROR] WordPress installation failed"; return 1; }
	create_user || return 1
}

# Check if WordPress is installed
# 2> -> redirect stderr, > -> redirect stdout => /dev/null -> ignore output by redirecting it to null
if ! wp core is-installed --allow-root 2>/dev/null ; then
    echo "[INFO] Installing WordPress..."
	install_wordpress || exit 1
    echo "[INFO] WordPress installation complete"
else
	if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1 ; then
		echo "[INFO] WordPress already installed, creating user ${WP_USER}"
		create_user || exit 1
		echo "[INFO] WordPress installation complete"
	else
		echo "[INFO] WordPress already installed, skipping installation"
	fi
fi

# Start PHP-FPM (by default php-fpm daemonizes/runs in background)
# -F -> stay in the foreground, required inside Docker
# (otherwise container would start, launch PHP-FPM in background, immediately exit)
echo "[INFO] Starting PHP-FPM..."
exec php-fpm8.2 -F