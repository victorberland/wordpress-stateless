FROM php:8.2-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
  ghostscript \
  libfreetype6-dev \
  libicu-dev \
  libjpeg-dev \
  libmagickwand-dev \
  libpng-dev \
  libwebp-dev \
  libzip-dev \
  zip \
  unzip \
  redis-server \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
  --with-freetype \
  --with-jpeg \
  --with-webp

RUN docker-php-ext-install \
  bcmath \
  exif \
  gd \
  intl \
  mysqli \
  zip

RUN pecl install redis imagick \
  && docker-php-ext-enable redis imagick \
  && rm -rf /tmp/pear

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
	docker-php-ext-enable opcache; \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
# https://wordpress.org/support/article/editing-wp-config-php/#configure-error-logging
RUN { \
# https://www.php.net/manual/en/errorfunc.constants.php
# https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /usr/local/etc/php/conf.d/error-logging.ini

RUN set -eux; \
	a2enmod rewrite expires; \
	\
# https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html
	a2enmod remoteip; \
	{ \
		echo 'RemoteIPHeader X-Forwarded-For'; \
# these IP ranges are reserved for "private" use and should thus *usually* be safe inside Docker
		echo 'RemoteIPTrustedProxy 10.0.0.0/8'; \
		echo 'RemoteIPTrustedProxy 172.16.0.0/12'; \
		echo 'RemoteIPTrustedProxy 192.168.0.0/16'; \
		echo 'RemoteIPTrustedProxy 169.254.0.0/16'; \
		echo 'RemoteIPTrustedProxy 127.0.0.0/8'; \
	} > /etc/apache2/conf-available/remoteip.conf; \
	a2enconf remoteip; \
# https://github.com/docker-library/wordpress/issues/383#issuecomment-507886512
# (replace all instances of "%h" with "%a" in LogFormat)
	find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +


# download latest WordPress and extract it to /var/www/html
RUN set -eux; \
	curl -o /tmp/wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz"; \
	tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1; \
	rm /tmp/wordpress.tar.gz; \
	chown -R www-data:www-data /var/www/html

# copy htaccess
COPY .htaccess /var/www/html/.htaccess

# uploads max size
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# download redis cache object cache dropin
RUN curl -o /tmp/object-cache.php -SL https://raw.githubusercontent.com/rhubarbgroup/redis-cache/master/includes/object-cache.php \
	&& mv /tmp/object-cache.php /var/www/html/wp-content/object-cache.php

# download advanced-cache.php to enable super-cache
RUN curl -o /tmp/advanced-cache.php -SL https://raw.githubusercontent.com/Automattic/wp-super-cache/trunk/advanced-cache.php \
	&& mv /tmp/advanced-cache.php /var/www/html/wp-content/advanced-cache.php

COPY wp-cache-config.php /var/www/html/wp-content/wp-cache-config.php

# download norwegian language pack
RUN curl -o /tmp/norwegian.zip -SL https://downloads.wordpress.org/translation/core/6.0/nb_NO.zip \
	&& unzip /tmp/norwegian.zip -d /var/www/html/wp-content/languages \
	&& rm /tmp/norwegian.zip

# permissions
COPY --chown=www-data:www-data wp-config-docker.php /var/www/html/wp-config.php
RUN chmod 640 /var/www/html/wp-config.php
RUN chown -R www-data:www-data /var/www/html/wp-content
RUN chmod -R 775 /var/www/html/wp-content

# entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# wp-config
COPY wp-config-docker.php /var/www/html/wp-config.php

# get-plugins script
COPY get-plugins.sh /usr/local/bin/get-plugins.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
