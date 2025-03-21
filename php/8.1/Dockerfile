# syntax=docker/dockerfile:1
FROM php:8.1-fpm

# 安裝 PHP 擴展及必要套件
RUN apt-get update && \
    apt-get install -y \
        git \
        unzip \
        curl \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libonig-dev \
        libpq-dev \
        libxml2-dev && \
    docker-php-ext-install pdo_mysql zip mbstring exif pcntl bcmath intl&& \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 Composer（使用指定版本，避免未來更新問題）
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# 設定工作目錄
WORKDIR /var/www/html

