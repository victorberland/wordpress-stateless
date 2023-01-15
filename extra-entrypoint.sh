echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

chown www-data:www-data /var/www
chown -R www-data:www-data /var/www/html
sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -owner -group -maxerrors 1000 &!

touch /var/spool/cron/crontabs/root

# cron sync
line="* * * * * sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -owner -group -maxerrors 1000 >> /var/www/unison.log 2>&1"
crontab -u root -l | { cat; echo "$line"; } | crontab -u root -
crontab -u root /var/spool/cron/crontabs/root
service cron restart
