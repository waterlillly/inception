#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
# exceptions:
#		- conditional statements (eg. [ if wp core install; then ... ] -> wont exit if installation fails)
#		- cmds with || or && (eg. [ wp core install || echo "fail" ] -> wont exit if installation fails)
# 		- pipelines (eg. [ wp core download | grep abc ] -> wont exit if download fails, only if grep fails)
set -e

# Read secrets from Docker secret files
DB_USER_PASS="$(cat /run/secrets/db_user_password)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"

# Validate required variables
: "${DOMAIN_NAME:?[ERROR] DOMAIN_NAME not set}"
: "${DB_NAME:?[ERROR] DB_NAME not set}"
: "${DB_USER:?[ERROR] DB_USER not set}"
: "${DB_USER_PASS:?[ERROR] DB_USER_PASS not set}"
: "${WP_TITLE:?[ERROR] WP_TITLE not set}"
: "${WP_ADMIN_USER:?[ERROR] WP_ADMIN_USER not set}"
: "${WP_ADMIN_EMAIL:?[ERROR] WP_ADMIN_EMAIL not set}"
: "${WP_ADMIN_PASS:?[ERROR] WP_ADMIN_PASS not set}"
: "${WP_USER:?[ERROR] WP_USER not set}"
: "${WP_USER_EMAIL:?[ERROR] WP_USER_EMAIL not set}"
: "${WP_USER_PASS:?[ERROR] WP_USER_PASS not set}"

cd /var/www/html

create_user() {
	if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1 ; then
		echo "[INFO] Creating user ${WP_USER}.."
		wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
			--role=author \
			--user_pass="${WP_USER_PASS}" \
			--allow-root || { echo "[ERROR] Failed to create user ${WP_USER}"; return 1; }
	fi
}

install_wordpress() {
	echo "[INFO] Installing WordPress.."
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASS}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root || { echo "[ERROR] WordPress installation failed"; return 1; }
}

create_config() {
	echo "[INFO] Configuring WordPress.."
	wp config create \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_USER_PASS}" \
		--dbhost="${DB_HOST}" \
		--allow-root || { echo "[ERROR] Failed to create wp-config.php"; return 1; }
}

download_wordpress() {
	echo "[INFO] Downloading WordPress.."
	wp core download --allow-root || { echo "[ERROR] WordPress download failed"; return 1; }
}

if ! wp core is-installed --allow-root 2>/dev/null ; then
	download_wordpress
	create_config
	install_wordpress
	create_user
fi

# Start PHP-FPM (by default php-fpm daemonizes/runs in background)
# -F -> stay in the foreground, required inside Docker
# (otherwise container would start, launch PHP-FPM in background, immediately exit)
echo "[INFO] Starting PHP-FPM..."
exec php-fpm8.2 -F