#!/usr/bin/env sh

# enables backend server in haproxy for ACME challenge validation

set -e
echo "set server letsencrypt/certbot state ready" | \
 socat /run/haproxy/admin.sock -
