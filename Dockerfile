FROM wordpress:latest
RUN apt-get update && apt-get install -y unison sshpass
RUN apt-get install -y cron sudo zip

COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# save last (exec) line to file
RUN tail -n 1 /usr/local/bin/docker-entrypoint.sh > /tmp/execline
RUN sed -i '$ d' /usr/local/bin/docker-entrypoint.sh

# append extras
COPY extra-entrypoint.sh /usr/local/bin/extra-entrypoint.sh
RUN cat /usr/local/bin/extra-entrypoint.sh >> /usr/local/bin/docker-entrypoint.sh

# download Redis WP plugin
RUN curl -L -o /var/www/html/wp-content/plugins/redis-object-cache.zip https://downloads.wordpress.org/plugin/redis-cache.2.2.3.zip
RUN unzip /var/www/html/wp-content/plugins/redis-object-cache.zip -d /var/www/html/wp-content/plugins/
RUN rm /var/www/html/wp-content/plugins/redis-object-cache.zip

# add back exec line
RUN cat /tmp/execline >> /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
