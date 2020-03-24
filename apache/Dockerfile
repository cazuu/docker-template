FROM php:7.3.13-apache-stretch
RUN apt-get update -y \
    && apt-get install -y libicu-dev libxml2-dev supervisor cron \
    && docker-php-ext-install xml intl mbstring pdo_mysql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get clean \
    && a2enmod rewrite

RUN { \
  echo 'xdebug.remote_enable=1'; \
} > /usr/local/etc/php/conf.d/overrides.ini

RUN { \
  echo "file_uploads = On"; \
  echo "memory_limit = 500M"; \
  echo "upload_max_filesize = 500M"; \
  echo "post_max_size = 500M"; \
  echo "max_execution_time = 600"; \
} > /usr/local/etc/php/conf.d/uploads.ini

COPY apache/cron.conf /etc/cron.d/user-cron
COPY apache/supervisord.conf /etc/supervisor/conf.d/process.conf

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
