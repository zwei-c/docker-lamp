# ./docker/php/7.3/Dockerfile
FROM php:7.3-fpm

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN usermod -u ${USER_ID} www-data && groupmod -g ${GROUP_ID} www-data

# 安裝必要套件與 Laravel 常用 PHP 擴展
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libssl-dev \
    libicu-dev \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-jpeg-dir=/usr/include \
        --with-webp-dir=/usr/include \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mbstring \
        xml \
        curl \
        zip \
        bcmath \
        opcache \
        gd \
        intl \
        exif \
        pcntl \
        sockets \
        calendar \
        gettext

# 複製自訂 php.ini 設定
COPY php.ini /usr/local/etc/php/php.ini

# 安裝 Redis 擴展 (指定 5.3.7 版本，這是最後支援 PHP 7.3 的版本)
RUN pecl install redis-5.3.7 && docker-php-ext-enable redis
