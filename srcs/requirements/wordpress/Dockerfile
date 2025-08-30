FROM debian:bookworm

LABEL maintainer="lbaumeis"

# side note: php8.2-fpm = package name, php-fpm8.2 = service/binary name
# Install PHP, extensions, and tools:
# - php: PHP core interpreter
# - php-fpm: FastCGI Process Manager for nginx integration
# - php-mysql: MySQL/MariaDB database connectivity
# - php-gd: Graphics library for image manipulation
# - php-xml: XML parsing for RSS feeds and sitemaps
# - php-curl: HTTP client for external API requests
# - php-zip: Archive handling for plugin/theme installation
# - curl: Command-line tool for downloading WordPress
# - tar: Archive extraction for WordPress files
# - mariadb-client: MySQL/MariaDB client for database access
# - ca-certificates: SSL/TLS certificates for HTTPS downloads
# apt-get clean -> removes cached .deb files
# rm -rf /var/lib/apt/lists/* -> removes package list indexes
# mkdir -p [...] -> creates necessary directories
# chown -R [...] -> changes ownership of files/directories to www-data (user under which PHP-FPM runs)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-gd \
        php8.2-xml \
        php8.2-curl \
        php8.2-zip \
        curl \
        tar \
        mariadb-client \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html /var/run/php/ /var/log/php-fpm \
    && chown -R www-data:www-data /var/run/php/ /var/www/html /var/log/php-fpm

# Install WP-CLI for WordPress management
RUN curl -L --fail --retry 3 --retry-connrefused -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && rm -rf /tmp/*

# Copy configurations and tools
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/wordpress.sh .
RUN chmod +x ./wordpress.sh

# Set working directory for WordPress
WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/wordpress.sh"]