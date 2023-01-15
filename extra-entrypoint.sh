echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

echo "extra-entrypoint.sh: running extra-entrypoint.sh"
echo "$1"

chown www-data:www-data /var/www
chown -R www-data:www-data /var/www/html
sudo -u www-data sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -dontchmod -perms 0 -maxerrors 1000 &!

# run nginx as daemon
nginx
# nginx -g "daemon off;"

# echo "running fpm:"
# php-fpm
# echo "fpm done"

# php-fpm -D
# touch /var/spool/cron/crontabs/www-data
#
# # cron sync
# line="* * * * * sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -dontchmod -perms 0 -maxerrors 1000 >> /var/www/unison.log 2>&1"
# crontab -u www-data -l | { cat; echo "$line"; } | crontab -u www-data -
# crontab -u www-data /var/spool/cron/crontabs/www-data
# service cron restart

