FROM debian:bookworm

# LABEL author=

# side note: php8.2-fpm = package name, php-fpm8.2 = service/binary name
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # php core interpreter:
        php8.2 \
        # php fastcgi process manager for nginx:
        php8.2-fpm \
        # mysql/mariadb database connectivity:
        php8.2-mysql \
        # graphics library (eg. media uploads):
        php8.2-gd \
        # core feature (eg. for admin dashboard):
        php8.2-xml \
        # http client for external api requests:
        php8.2-curl \
        # for downloading wp-cli:
        curl \
        # mysql/mariadb client for database access:
        mariadb-client \
        # SSL/TLS certificates for HTTPS downloads:
        ca-certificates \
        # networking utility for health checks:
        netcat-openbsd \
    # remove cached .deb files:
    && apt-get clean \
    # remove package list indexes:
    && rm -rf /var/lib/apt/lists/* \
    # create necessary directories:
    && mkdir -p /var/www/html /var/run/php/ /var/log/php-fpm \
    # change ownership to www-data (php-fpm/nginx user):
    && chown -R www-data:www-data /var/run/php/ /var/www/html /var/log/php-fpm \
    # -L -> follows redirects, -o wp-cli.phar [...] -> specifies output filename for the download
    # wp-cli -> wordpress-command line interface (=tool for wp operations in entrypoint script)
    && curl -L -o wp-cli.phar \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    # phar = php archive, chmod makes it executable:
    && chmod +x wp-cli.phar \
    # install as 'wp' command to then use in script:
    && mv wp-cli.phar /usr/local/bin/wp \
    # remove temporary files:
    && rm -rf /tmp/*

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/wordpress.sh .

RUN chmod +x ./wordpress.sh

# sets default dir for wordpress (if docker exec is run -> starts here)
WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/wordpress.sh"]