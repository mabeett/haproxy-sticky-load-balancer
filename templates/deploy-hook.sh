#!/bin/bash

# echo 'set server letsencrypt/certbot health down' | socat /run/haproxy/admin.sock -
# echo 'set server letsencrypt/certbot health up' | socat /run/haproxy/admin.sock -

## echo 'set server letsencrypt/certbot state maint' | socat /run/haproxy/admin.sock -
## echo 'set server letsencrypt/certbot state ready' | socat /run/haproxy/admin.sock -

DEST_CERTS="${DEST_CERTS:-{{ frontendshttps[0].crtdir | default(default_frontendhttps_crtdir) }}}"
CRT_FILE="${CRT_FILE:-{{ frontendshttps[0].crtfile | default(default_frontendhttps_crtfile) }}}"

set -e
# $RENEWED_LINEAGE will point to the
# config live subdirectory (for example,
# "/etc/letsencrypt/live/example.com") containing the
# new certificates and keys;
# the shell variable
# $RENEWED_DOMAINS will contain a space-delimited list
# of renewed certificate domains (for example,
# "example.com www.example.com"

for domain in "${RENEWED_DOMAINS}"
do
  if [ "{{ certbot.domain }}" = "${domain}" ]
  then
    echo "Copying new certificates for \"${domain}\"..."
    cp -L "${RENEWED_LINEAGE}/fullchain.pem" "${DEST_CERTS}/${domain}.crt"
    cp -L "${RENEWED_LINEAGE}/privkey.pem" "${DEST_CERTS}/${domain}.key"
    cp -L "${RENEWED_LINEAGE}/chain.pem" "${DEST_CERTS}/${domain}.chain.pem"
    cat "${RENEWED_LINEAGE}/fullchain.pem" "${RENEWED_LINEAGE}/privkey.pem" > "${DEST_CERTS}/${CRT_FILE}"
  fi
done
