FROM node:16.16 as node
FROM php:7.4-apache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules/

RUN apt-get update -y \
    && apt-get install -y libicu-dev libxml2-dev supervisor cron libmagickwand-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev locales git libonig-dev \
    && docker-php-ext-install xml intl pdo_mysql \
#    && pecl install xdebug \
#    && docker-php-ext-enable xdebug \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install zip \
    && docker-php-ext-install gd \
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
#    && \
#    { \
#      echo 'xdebug.remote_enable=1'; \
#    } > /usr/local/etc/php/conf.d/overrides.ini \
    && \
    { \
      echo "file_uploads = On"; \
      echo "memory_limit = 500M"; \
      echo "upload_max_filesize = 500M"; \
      echo "post_max_size = 500M"; \
      echo "max_execution_time = 600"; \
    } > /usr/local/etc/php/conf.d/uploads.ini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite

# timezone environment
ENV TZ=UTC \
  # locale
  LANG=ja_JP.UTF-8 \
  LANGUAGE=ja_JP:ja \
  LC_ALL=ja_JP.UTF-8 \
  # composer environment
  COMPOSER_ALLOW_SUPERUSER=1

COPY apache/cron.conf /etc/cron.d/user-cron
COPY apache/supervisord.conf /etc/supervisor/conf.d/process.conf

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
