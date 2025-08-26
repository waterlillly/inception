FROM debian:bullseye

LABEL maintainer="lbaumeis"

# Install PHP, extensions, and tools:
# - php: PHP  core interpreter
# - php-fpm: FastCGI Process Manager for nginx integration
# - php-mysql: MySQL/MariaDB database connectivity
# - php-gd: Graphics library for image manipulation
# - php-xml: XML parsing for RSS feeds and sitemaps
# - php-curl: HTTP client for external API requests
# - php-zip: Archive handling for plugin/theme installation
# - curl: Command-line tool for downloading WordPress
# - wget: Alternative download utility
# - tar: Archive extraction for WordPress files
# - mariadb-client: MySQL/MariaDB client for database access
RUN apt-get update \
    && apt-get install -y \
	php \
	php-fpm \
	php-mysql \
	php-gd \
	php-xml \
	php-curl \
	php-zip \
	curl \
	wget \
	tar \
	mariadb-client \
	&& apt clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir -p /var/www/html \
    && mkdir -p /var/run/php/ \
    && chown -R www-data:www-data /var/run/php/ /var/www/html

# Set working directory and ensure proper ownership
# WORKDIR /var/www/html
# RUN chown -R www-data:www-data /var/www/html
    # && mkdir -p /var/log \
    # && touch /var/log/php-fpm.log \
    # && chown www-data:www-data /var/log/php-fpm.log

# Install WP-CLI for WordPress management
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy configurations and tools
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/wordpress.sh .
RUN chmod +x ./wordpress.sh

EXPOSE 9000

ENTRYPOINT ["./wordpress.sh"]