FROM debian:bookworm

# LABEL author=

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/ssl/private /etc/ssl/certs \
    && chown root:root /etc/ssl/private /etc/ssl/certs \
    && chmod 700 /etc/ssl/private \
    && chmod 755 /etc/ssl/certs

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/nginx.sh .

RUN chmod +x nginx.sh

EXPOSE 443

# ENTRYPOINT defines the executable that runs (can't be overridden)
# CMD would provide default arguments to ENTRYPOINT, or run standalone if no ENTRYPOINT
ENTRYPOINT ["./nginx.sh"]