#!/bin/bash

URL=$1

# get plugins
rm -rf /var/www/html/wp-content/plugins
curl -o /tmp/plugins.zip -SL $URL/wp-content/plugins/serverless/index.php?serverless_get_plugins=1
unzip -o /tmp/plugins.zip -d /var/www/html/wp-content/plugins
rm /tmp/plugins.zip
chown -R www-data:www-data /var/www/html/wp-content/plugins

# remove hello dolly
rm -rf /var/www/html/wp-content/plugins/hello.php

# remove akismet
rm -rf /var/www/html/wp-content/plugins/akismet

# ensure permissions
chown -R www-data:www-data /var/www/html/wp-content/plugins

