#!/usr/bin/env bash
set -Eeuo pipefail
# chown -R www-data:www-data /var/www/html


# cron for wp-cron
line="* * * * * www-data /usr/local/bin/php /var/www/html/wp-cron.php > /dev/null 2>&1"
touch /var/spool/cron/crontabs/www-data
crontab -u www-data -l | { cat; echo "$line"; } | crontab -u www-data -
crontab -u www-data /var/spool/cron/crontabs/www-data
service cron restart

service redis-server restart
exec "$@"
