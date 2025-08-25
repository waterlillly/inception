FROM debian:bullseye

# Install PHP, extensions, and tools:
# - php7.4: PHP 7.4 core interpreter
# - php7.4-fpm: FastCGI Process Manager for nginx integration
# - php7.4-mysql: MySQL/MariaDB database connectivity
# - php7.4-gd: Graphics library for image manipulation
# - php7.4-xml: XML parsing for RSS feeds and sitemaps
# - php7.4-curl: HTTP client for external API requests
# - php7.4-zip: Archive handling for plugin/theme installation
# - curl: Command-line tool for downloading WordPress
# - wget: Alternative download utility
# - tar: Archive extraction for WordPress files
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
	php7.4 \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-gd \
	php7.4-xml \
	php7.4-curl \
	php7.4-zip \
	curl \
	wget \
	tar \
	mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/php/ \
    && chown -R www-data:www-data /var/run/php/

# Set working directory and ensure proper ownership
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && mkdir -p /var/log \
    && touch /var/log/php7.4-fpm.log \
    && chown www-data:www-data /var/log/php7.4-fpm.log

# Install WP-CLI for WordPress management
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy configurations and tools
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/wordpress.sh .
RUN chmod +x ./wordpress.sh

# Switch to non-root user for security
USER www-data

EXPOSE 9000

ENTRYPOINT ["./wordpress.sh"]