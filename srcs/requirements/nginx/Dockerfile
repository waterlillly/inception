FROM debian:bullseye

LABEL maintainer="lbaumeis"

# Update system and install nginx + openssl
# rm -rf line removes the cache of the package manager
RUN apt-get update \
    && apt-get install -y nginx openssl \
	&& apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/ssl/private /etc/ssl/certs

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY /tools/nginx.sh .

RUN chmod +x nginx.sh

EXPOSE 443

ENTRYPOINT ["./nginx.sh"]