FROM debian:bullseye

LABEL maintainer="lbaumeis"

RUN apt-get update \
    && apt-get install -y mariadb-server \
	&& apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# NOTES:
# MariaDB specific config-file hierarchy:
# 	1. /etc/mysql/my.cnf (main config file)
# 	2. /etc/mysql/conf.d/ (general config files)
# 	3. /etc/mysql/mariadb.conf.d/ (MariaDB specific config files, separate from generic MySQL)
#
# Number prefix controls the loading order:
# 	- 10-*.cnf (system/package defaults)
# 	- 50-*.cnf (custom server configs)
# 	- 60-*.cnf (client configs)
# 	- 99-*.cnf (final overrides)

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/mariadb.sh .

RUN chmod +x ./mariadb.sh

USER mysql

EXPOSE 3306

ENTRYPOINT ["./mariadb.sh"]
