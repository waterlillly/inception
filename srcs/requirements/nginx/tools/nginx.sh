#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
set -e

# Generate self-signed SSL certificate for HTTPS:
# openssl req -> command to create certificate (request)
# -x509 -> create self-signed certificate
# -nodes -> no password for private key
# -newkey rsa:2048 -> create new RSA key of 2048 bits
# -days 365 -> valid for 365 days
# -keyout -> specify the output file for the private key
# -out -> specify the output file for the certificate
# -subj -> specify the subject information (Country, State, Locality, Organization, Organizational Unit, Common Name)
openssl req \
    -x509 \
	-nodes \
	-newkey rsa:2048 \
    -days 365 \
    -keyout ${SSL_KEY_FILE} \
    -out ${SSL_CERT_FILE} \
    -subj "/C=AT/ST=Austria/L=Vienna/O=42Vienna/OU=student/CN=${USER}"

# Substitute environment variables in nginx config
# sed -i -> edit file in-place
# Substitute all occurences of DOMAIN_NAME with the value of $DOMAIN_NAME (env-variable)
# /g -> all occurences in each line
sed -i "s/DOMAIN_NAME/$DOMAIN_NAME/g" /etc/nginx/nginx.conf
sed -i "s|\${SSL_CERT_FILE}|$SSL_CERT_FILE|g" /etc/nginx/nginx.conf
sed -i "s|\${SSL_KEY_FILE}|$SSL_KEY_FILE|g" /etc/nginx/nginx.conf

# Start nginx, allow passing nginx config directives, start in foreground (would exit otherwise after starting)
exec nginx -g "daemon off;"