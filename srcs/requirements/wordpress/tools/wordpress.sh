#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
set -e

# Read secrets from Docker secret files
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"${DB_USER}" -p"${DB_PASSWORD}" --silent; do
    sleep 2
done
echo "MariaDB is ready!"

# Check if WordPress is already downloaded
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    echo "WordPress download complete!"
else
    echo "WordPress already downloaded, skipping download..."
fi

# Always create/update wp-config.php with current database settings
echo "Configuring WordPress..."
wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost="${DB_HOST}" --allow-root --force

# Check if WordPress is installed (has admin user)
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install --url="https://${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --allow-root
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
    echo "WordPress installation complete!"
    
    # Install and activate a custom theme
    echo "Installing custom theme..."
    wp theme install oceanwp --activate --allow-root
    
    # Install useful plugins
    echo "Installing plugins..."
    wp plugin install elementor --activate --allow-root
    wp plugin install contact-form-7 --activate --allow-root
    
    echo "Theme and plugins installation complete!"
else
    echo "WordPress already installed, skipping installation..."
fi

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec php-fpm7.4 -F