FROM wordpress:fpm-alpine
RUN apk add --no-cache unison sshpass sudo zip unzip nginx openssh openrc
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

RUN tail -n 1 /usr/local/bin/docker-entrypoint.sh > /tmp/execline
RUN sed -i '$ d' /usr/local/bin/docker-entrypoint.sh

# append extras
COPY extra-entrypoint.sh /usr/local/bin/extra-entrypoint.sh
RUN cat /usr/local/bin/extra-entrypoint.sh >> /usr/local/bin/docker-entrypoint.sh

# add back exec line
RUN cat /tmp/execline >> /usr/local/bin/docker-entrypoint.sh
RUN rm /tmp/execline

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY wordpress-fpm.conf /etc/nginx/http.d/default.conf

CMD ["php-fpm"]

# CMD ["nginx", "-g", "daemon off;"]
# run php-fpm in background and nginx in foreground
# CMD ["php-fpm", "-F", "-R", "&&", "nginx", "-g", "daemon off;"]
# CMD ["php-fpm", "-D", "&&", "nginx", "-g", "daemon off;"]
