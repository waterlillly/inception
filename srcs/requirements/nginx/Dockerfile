FROM debian:bookworm

LABEL maintainer="lbaumeis"

# Optimize package installation for smaller image size
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && apt-get autoremove -y \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives/* \
    && mkdir -p /etc/ssl/private /etc/ssl/certs \
    && chown root:root /etc/ssl/private /etc/ssl/certs \
    && chmod 700 /etc/ssl/private \
    && chmod 755 /etc/ssl/certs

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/nginx.sh .

RUN chmod +x nginx.sh

EXPOSE 443

ENTRYPOINT ["./nginx.sh"]