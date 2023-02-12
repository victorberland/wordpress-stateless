#!/usr/bin/env bash
set -Eeuo pipefail

chown -R www-data:www-data /var/www/html

# get last line of wp-config.php
last_line=$(tail -n 1 /var/www/html/wp-config.php)
# remove last line of wp-config.php
sed -i '$ d' /var/www/html/wp-config.php
# add new line to wp-config.php
echo "define('WP_CACHE', true);" >> /var/www/html/wp-config.php
echo "define('WPCACHEHOME', '/var/www/html/wp-content/plugins/wp-super-cache/');" >> /var/www/html/wp-config.php
echo "define('DISABLE_WP_CRON', true);" >> /var/www/html/wp-config.php
# add last line to wp-config.php
echo $last_line >> /var/www/html/wp-config.php

service redis-server restart
exec "$@"
