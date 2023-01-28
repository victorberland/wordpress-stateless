echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

chown www-data:www-data /var/www
chown -R www-data:www-data /var/www/html

touch /var/www/unison.log
chown www-data:www-data /var/www/unison.log

echo "export HOME=/var/www" >> /etc/apache2/envvars

sudo -u www-data sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -dontchmod -ignorearchives -prefer newer -perms 0 -maxerrors 1000 &!

touch /var/spool/cron/crontabs/www-data

# cron sync
line="*/5 * * * * sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -dontchmod -ignorearchives -prefer newer -perms 0 -maxerrors 1000 >> /var/www/unison.log 2>&1"
crontab -u www-data -l | { cat; echo "$line"; } | crontab -u www-data -
crontab -u www-data /var/spool/cron/crontabs/www-data
service cron restart
