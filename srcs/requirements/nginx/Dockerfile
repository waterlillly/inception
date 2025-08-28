FROM debian:bookworm

LABEL maintainer="lbaumeis"

# Update system and install nginx + openssl
# rm -rf /var/lib/apt/lists/* -> removes package list indexes
# apt-get clean -> removes cached .deb files.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
    && rm -rf /var/lib/apt/lists/* \
	&& apt-get clean \
    && mkdir -p /etc/ssl/private /etc/ssl/certs \
    && chown root:root /etc/ssl/private /etc/ssl/certs \
    && chmod 700 /etc/ssl/private \
    && chmod 755 /etc/ssl/certs

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY /tools/nginx.sh .

RUN chmod +x nginx.sh

EXPOSE 443

ENTRYPOINT ["./nginx.sh"]