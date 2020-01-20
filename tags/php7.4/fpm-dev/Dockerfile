FROM ivandotv/wordpress:php7.4-fpm-base

ENV WP_ENV='development' \
    XDEBUG_VERSION='2.9.1'

# install xdebug extension
RUN pecl install xdebug-${XDEBUG_VERSION}

RUN ( \
    echo zend_extension=xdebug.so;  \
    echo xdebug.remote_enable=1;  \
    echo xdebug.remote_autostart=0;  \
    echo xdebug.remote_connect_back=1; \
    echo xdebug.remote_port=9000; \
    ) > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


# setup development php configuration
# disable opcache
RUN ( \
    echo opcache.enable=0; \
    echo opcache.enable_cli=0; \
    ) > /usr/local/etc/php/conf.d/opcache-dev.ini
