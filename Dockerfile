FROM wordpress:latest
RUN apt-get update && apt-get install -y redis-server zip

COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

RUN curl -o /tmp/latest.tar.gz -SL https://wordpress.org/latest.tar.gz \
		&& tar -xzf /tmp/latest.tar.gz -C /usr/src/wordpress --strip-components=1 \
		&& rm /tmp/latest.tar.gz \
		&& chown -R www-data:www-data /usr/src/wordpress

# remove akismet and hello dolly
RUN rm -rf /usr/src/wordpress/wp-content/plugins/akismet \
		&& rm -rf /usr/src/wordpress/wp-content/plugins/hello.php

COPY mu-plugins /usr/src/wordpress/wp-content/mu-plugins
COPY plugins /usr/src/wordpress/wp-content/plugins

# download redis-cache plugin
RUN curl -o /tmp/redis-cache.zip -SL https://downloads.wordpress.org/plugin/redis-cache.1.3.8.zip \
		&& unzip /tmp/redis-cache.zip -d /usr/src/wordpress/wp-content/plugins \
		&& rm /tmp/redis-cache.zip

# save last (exec) line to file
RUN tail -n 1 /usr/local/bin/docker-entrypoint.sh > /tmp/execline
RUN sed -i '$ d' /usr/local/bin/docker-entrypoint.sh

# append extras
COPY extra-entrypoint.sh /usr/local/bin/extra-entrypoint.sh
RUN cat /usr/local/bin/extra-entrypoint.sh >> /usr/local/bin/docker-entrypoint.sh

# add back exec line
RUN cat /tmp/execline >> /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
