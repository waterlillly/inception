#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
set -e

# Read secrets from Docker secret files
SSL_KEY=$(cat /run/secrets/ssl_key)
SSL_CERT=$(cat /run/secrets/ssl_cert)

# Create SSL certificate directory if it doesn't exist
mkdir -p $(dirname ${SSL_KEY})

# Generate self-signed SSL certificate for HTTPS:
# openssl req -> command to create certificate (request)
# -x509 -> create self-signed certificate
# -nodes -> no password for private key
# -newkey rsa:2048 -> create new RSA key of 2048 bits
# -days 365 -> valid for 365 days
# -keyout -> specify the output file for the private key
# -out -> specify the output file for the certificate
# -subj -> specify the subject information (Country, Locality, Organization, Organizational Unit, Common Name)
openssl req \
    -x509 \
	-nodes \
	-newkey rsa:2048 \
    -days 365 \
    -keyout ${SSL_KEY} \
    -out ${SSL_CERT} \
    -subj "/C=AT/L=Vienna/O=42Vienna/OU=student/CN=${DOMAIN_NAME}"

# Substitute environment variables in nginx config
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Start nginx in foreground mode
exec nginx -g "daemon off;"