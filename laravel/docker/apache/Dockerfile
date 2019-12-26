FROM php:7.3.13-apache-stretch
RUN apt-get update -y \
    && apt-get install -y libicu-dev libxml2-dev cron \
    && docker-php-ext-install xml intl mbstring pdo_mysql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get clean \
    && a2enmod rewrite

RUN { \
  echo 'xdebug.remote_enable=1'; \
} > /usr/local/etc/php/conf.d/overrides.ini
