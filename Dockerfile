FROM composer:2.9.2 AS composer

FROM php:8.4.15-fpm AS php

# Common instructions
RUN apt-get update && \
    # Add ru_RU.UTF-8 locale
    apt-get -y install locales && \
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=ru_RU.UTF-8

ENV LANG ru_RU.UTF-8

# Install ext zip
RUN apt-get install -y zip && \
    apt-get install -y libzip-dev && \
    docker-php-ext-install zip

# Install ext intl
RUN apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Install ext sockets
RUN docker-php-ext-install sockets

# Install composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Install dependencies
COPY . /var/www/html
RUN composer install

FROM php AS app-fpm

FROM php AS app-rr

RUN ./vendor/bin/rr get-binary --location bin/

EXPOSE 8080

CMD ["bin/rr", "serve", "--config", ".rr.yaml"]

FROM app-rr AS app-rr-fork

RUN composer config repositories.fork --json '{"type":"package","package":{"name":"baldinof/roadrunner-bundle","version":"dev-streamed-respond","dist":{"url":"https://github.com/Kenny1911/roadrunner-bundle/archive/refs/heads/streamed-respond.zip","type":"zip"},"autoload":{"files":["src/functions.php"],"psr-4":{"Baldinof\\RoadRunnerBundle\\":"src"}}}}'
RUN composer require --update-with-all-dependencies baldinof/roadrunner-bundle:dev-streamed-respond
