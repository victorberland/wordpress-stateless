#!/bin/bash

URL=$1

# get plugins
rm -rf /var/www/html/wp-content/plugins
curl -o /tmp/plugins.zip -SL $URL/wp-content/plugins/stateless/index.php?stateless_get_plugins=1&stateless_plugins_key=$STATELESS_PLUGINS_KEY
unzip -o /tmp/plugins.zip -d /var/www/html/wp-content/plugins
rm /tmp/plugins.zip
chown -R www-data:www-data /var/www/html/wp-content/plugins

# remove hello dolly
rm -rf /var/www/html/wp-content/plugins/hello.php

# download latest version of akismet
curl -o /tmp/akismet.zip -SL https://downloads.wordpress.org/plugin/akismet.latest-stable.zip
unzip -o /tmp/akismet.zip -d /var/www/html/wp-content/plugins
rm /tmp/akismet.zip

# download latest version of redis object cache
curl -o /tmp/redis-object-cache.zip -SL https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip
unzip -o /tmp/redis-object-cache.zip -d /var/www/html/wp-content/plugins
rm /tmp/redis-object-cache.zip

# download latest version of wp super cache
curl -o /tmp/wp-super-cache.zip -SL https://downloads.wordpress.org/plugin/wp-super-cache.latest-stable.zip
unzip -o /tmp/wp-super-cache.zip -d /var/www/html/wp-content/plugins
rm /tmp/wp-super-cache.zip

# plugins from image
mv -n /opt/plugins/* /var/www/html/wp-content/plugins

# list plugins
echo "Plugins folder now contains:"
ls /var/www/html/wp-content/plugins

# ensure permissions
chown -R www-data:www-data /var/www/html/wp-content/plugins
chmod -R 755 /var/www/html/wp-content/plugins
