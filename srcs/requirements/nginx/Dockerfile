FROM debian:bullseye

# Update system and install nginx + openssl
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y nginx openssl gettext-base \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/ssl/private

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY /tools/nginx.sh .

RUN chmod +x nginx.sh

EXPOSE 443

ENTRYPOINT ["./nginx.sh"]