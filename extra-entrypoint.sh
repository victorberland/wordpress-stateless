echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

SSH_PATH_VAR=""
if [ -n "$SSH_PATH" ]; then
	SSH_PATH_VAR="$SSH_PATH"
fi

chown www-data:www-data /var/www
chown -R www-data:www-data /var/www/html
sudo -u www-data sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/$SSH_PATH_VAR -auto -dontchmod -perms 0 -maxerrors 1000 &!

touch /var/spool/cron/crontabs/www-data

# cron sync
line="* * * * * sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/$SSH_PATH_VAR -auto -dontchmod -perms 0 -maxerrors 1000 >> /var/www/unison.log 2>&1"
crontab -u www-data -l | { cat; echo "$line"; } | crontab -u www-data -
crontab -u www-data /var/spool/cron/crontabs/www-data
service cron restart
