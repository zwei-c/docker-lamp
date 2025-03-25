# ./docker/php/8.0/Dockerfile
FROM php:8.0-fpm

# 安裝必要套件與 Laravel 常用 PHP 擴展
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mbstring \
        xml \
        curl \
        zip \
        bcmath \
        opcache

# 複製自訂 php.ini 設定
COPY php.ini /usr/local/etc/php/php.ini
