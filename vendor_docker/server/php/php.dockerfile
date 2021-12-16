FROM php:7.4.26-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y git unzip zip libzmq3-dev

WORKDIR /var/www/html/public

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions gd pdo_mysql bcmath zip intl opcache

COPY --from=composer:2.0 /usr/bin/composer /usr/local/bin/composer

RUN git clone git://github.com/mkoppanen/php-zmq.git \
 && cd php-zmq \
 && phpize && ./configure \
 && make \
 && make install \
 && cd .. \
 && rm -fr php-zmq

RUN pecl install redis-5.1.1 \
    && pecl install xdebug-2.8.1 \
    && docker-php-ext-enable redis xdebug zmq
