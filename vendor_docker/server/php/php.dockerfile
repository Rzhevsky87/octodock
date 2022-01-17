ARG PHP_VERSION
ARG USER_ID
ARG GROUP_ID

FROM php:${PHP_VERSION:-8.0}-apache

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

RUN pecl install redis-5.3.5 \
    && pecl install xdebug-3.1.2 \
    && docker-php-ext-enable redis xdebug zmq

RUN userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID:-1000} www-data &&\
    useradd -l -u ${USER_ID:-1000} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /home/www-data &&\
    chown --changes --silent --no-dereference --recursive \
              --from=33:33 ${USER_ID:-1000}:${GROUP_ID:-1000} \
            /var/www/html/public

USER www-data
