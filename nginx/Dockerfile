# syntax=docker/dockerfile:1
FROM nginx:latest

# 安裝certbot與相關套件

RUN apt-get update && apt-get install -y nginx \
        certbot \
        python3-certbot-nginx \
        cron && \
        apt-get clean && rm -rf /var/lib/apt/lists/*

# 設定工作目錄
WORKDIR /var/www/html


