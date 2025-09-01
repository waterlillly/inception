#!/bin/bash

set -e

# Validate required variables (or exit)
: "${DOMAIN_NAME:?[ERROR] DOMAIN_NAME not set}"
: "${SSL_CERT_FILE:?[ERROR] SSL_CERT_FILE not set}"
: "${SSL_KEY_FILE:?[ERROR] SSL_KEY_FILE not set}"

# Generate request for a self-signed SSL certificate
# -x509 -> create self-signed certificate
# -nodes -> no password for private key
# -newkey rsa:2048 -> create new RSA key of 2048 bits
# -days 365 -> valid for 365 days
# -keyout -> specify out file for private key
# -out -> specify out file for certificate
# -subj -> specify subject info (country, state, locality, org, org-unit, common name)
openssl req \
    -x509 \
	-nodes \
	-newkey rsa:2048 \
    -days 365 \
    -keyout "${SSL_KEY_FILE}" \
    -out "${SSL_CERT_FILE}" \
    -subj "/C=AT/ST=Austria/L=Vienna/O=42Vienna/OU=student/CN=${DOMAIN_NAME}" \
	|| { echo "[ERROR] Failed to generate SSL certificate"; exit 1; }

# Substitute environment variables in nginx config
# sed -> stream editor, -i -> edit files in place, '|' -> delimiter, s -> substitute, g -> all occurences in each line
sed -i "s|DOMAIN_NAME|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute DOMAIN_NAME"; exit 1; }
sed -i "s|SSL_CERT_FILE|${SSL_CERT_FILE}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute SSL_CERT_FILE"; exit 1; }
sed -i "s|SSL_KEY_FILE|${SSL_KEY_FILE}|g" /etc/nginx/nginx.conf || { echo "[ERROR] Failed to substitute SSL_KEY_FILE"; exit 1; }

# Start nginx in foreground (daemon off) so it stays PID 1 for proper signal handling
# -g -> command line config overrides (needed to prevent nginx from daemonizing)
echo "[INFO] Starting nginx.."
exec nginx -g "daemon off;"