#!/bin/bash

# Enable strict error handling -> stops the script if anything goes wrong
# although mostly already handled by me (error logs and exiting)
set -e

# Validate required variables (otherwise exit)
: "${DOMAIN_NAME:?[ERROR] DOMAIN_NAME not set}"
: "${SSL_CERT_FILE:?[ERROR] SSL_CERT_FILE not set}"
: "${SSL_KEY_FILE:?[ERROR] SSL_KEY_FILE not set}"

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
    -keyout "${SSL_KEY_FILE}" \
    -out "${SSL_CERT_FILE}" \
    -subj "/C=AT/ST=Austria/L=Vienna/O=42Vienna/OU=student/CN=${LOGIN}" || { echo "[ERROR] Failed to generate SSL certificate"; exit 1; }

# Substitute environment variables in nginx config
# sed -i -> edit file in-place
# Substitute all occurences of placeholders with environment variable values
# /g -> all occurences in each line
sed -i "s|DOMAIN_NAME|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute DOMAIN_NAME"; exit 1; }
sed -i "s|SSL_CERT_FILE|${SSL_CERT_FILE}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute SSL_CERT_FILE"; exit 1; }
sed -i "s|SSL_KEY_FILE|${SSL_KEY_FILE}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute SSL_KEY_FILE"; exit 1; }

# Start nginx
# -g allows passing nginx config directives
# "daemon off" starts in foreground (would exit otherwise after starting)
echo "[INFO] Starting nginx.."
exec nginx -g "daemon off;"