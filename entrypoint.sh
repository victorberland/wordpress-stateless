#!/usr/bin/env bash
set -Eeuo pipefail
chown -R www-data:www-data /var/www/html
service redis-server restart
exec "$@"
