FROM php:7.3-fpm

RUN apt-get update -y
RUN apt-get -y install gcc make autoconf libc-dev pkg-config libzip-dev

RUN apt-get install -y --no-install-recommends \
    nodejs npm git imagemagick vim-tiny \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libssl-dev libssl-doc libsasl2-dev \
    libmcrypt-dev \
    libxml2-dev \
    zlib1g-dev libicu-dev g++ \
    libldap2-dev libbz2-dev \
    curl libcurl4-openssl-dev \
    libenchant-dev libgmp-dev firebird-dev libib-util \
    re2c libpng++-dev \
    libwebp-dev libjpeg-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libfreetype6-dev \
    libmagick++-dev \
    libmagickwand-dev \
    zlib1g-dev libgd-dev \
    libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
    sqlite3 libsqlite3-dev libxslt-dev \
    libmhash2 libmhash-dev libc-client-dev libkrb5-dev libssh2-1-dev \
    unzip libpcre3 libpcre3-dev libncurses5 librdkafka-dev\
    poppler-utils ghostscript libmagickwand-6.q16-dev libsnmp-dev libedit-dev libreadline6-dev libsodium-dev \
    freetds-bin freetds-dev freetds-common libct4 libsybdb5 tdsodbc libreadline-dev librecode-dev libpspell-dev \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN npm install -g yarn

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN pecl install rdkafka && docker-php-ext-enable rdkafka
RUN pecl install ssh2-alpha && docker-php-ext-enable ssh2
RUN docker-php-ext-install interbase intl mbstring mysqli soap opcache zip

RUN pecl install imagick && \
    pecl install redis && \
    pecl install memcached && \
    pecl install mcrypt-1.0.3 && \
    docker-php-ext-enable imagick redis memcached

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

RUN docker-php-ext-configure gd \
        --with-png-dir \
        --with-jpeg-dir \
        --with-xpm-dir \
        --with-webp-dir \
        --with-freetype-dir \
        && docker-php-ext-install -j$(nproc) gd

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
        && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
        && php composer-setup.php \
        && php -r "unlink('composer-setup.php');" \
        && mv composer.phar /usr/local/sbin/composer \
        && chmod +x /usr/local/sbin/composer

ADD ./php.ini /etc/php/7.3/fpm/conf.d/90-php.ini
ADD ./php.ini /etc/php/7.3/cli/conf.d/90-php.ini

RUN usermod -u 10000 www-data

WORKDIR "/var/www/html"

EXPOSE 9000
