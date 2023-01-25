FROM wordpress:latest
RUN apt-get update && apt-get install -y unison sshpass
RUN apt-get install -y cron sudo zip

COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# copy mu-plugins folder
# COPY mu-plugins /usr/src/wordpress/wp-content/mu-plugins

# save last (exec) line to file
RUN tail -n 1 /usr/local/bin/docker-entrypoint.sh > /tmp/execline
RUN sed -i '$ d' /usr/local/bin/docker-entrypoint.sh

# append extras
COPY extra-entrypoint.sh /usr/local/bin/extra-entrypoint.sh
RUN cat /usr/local/bin/extra-entrypoint.sh >> /usr/local/bin/docker-entrypoint.sh

# add back exec line
RUN cat /tmp/execline >> /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
