#!/usr/bin/env sh

# restarts haproxy service after certificate installation

set -e
/bin/systemctl restart haproxy
