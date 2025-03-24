FROM ubuntu:24.04

# 安裝必要工具與 PHP 多版本來源
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    unzip \
    zip \
    lsb-release \
    sudo \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# 加入 PHP 多版本 PPA
RUN add-apt-repository ppa:ondrej/php && apt-get update

# 安裝 PHP 7.3, 7.4（基本模組），8.0, 8.1, 8.3（完整 Artisan 支援模組）
RUN apt-get install -y \
    php7.3 php7.3-cli php7.3-mbstring php7.3-xml php7.3-curl php7.3-zip \
    php7.4 php7.4-cli php7.4-mbstring php7.4-xml php7.4-curl php7.4-zip \
    php8.0 php8.0-cli php8.0-mbstring php8.0-xml php8.0-curl php8.0-zip php8.0-bcmath php8.0-tokenizer php8.0-mysql php8.0-common php8.0-ctype php8.0-dom php8.0-fileinfo php8.0-pdo php8.0-readline \
    php8.1 php8.1-cli php8.1-mbstring php8.1-xml php8.1-curl php8.1-zip php8.1-bcmath php8.1-tokenizer php8.1-mysql php8.1-common php8.1-ctype php8.1-dom php8.1-fileinfo php8.1-pdo php8.1-readline \
    php8.3 php8.3-cli php8.3-mbstring php8.3-xml php8.3-curl php8.3-zip php8.3-bcmath php8.3-tokenizer php8.3-mysql php8.3-common php8.3-ctype php8.3-dom php8.3-fileinfo php8.3-pdo php8.3-readline \
    && rm -rf /var/lib/apt/lists/*

# 建立 PHP 切換機制
RUN update-alternatives --install /usr/bin/php php /usr/bin/php7.3 73 \
    && update-alternatives --install /usr/bin/php php /usr/bin/php7.4 74 \
    && update-alternatives --install /usr/bin/php php /usr/bin/php8.0 80 \
    && update-alternatives --install /usr/bin/php php /usr/bin/php8.1 81 \
    && update-alternatives --install /usr/bin/php php /usr/bin/php8.3 83

# 加入 alias php-switch
RUN echo "alias php-switch='sudo update-alternatives --config php'" >>/root/.bashrc

# 安裝 Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# 安裝 Node.js (LTS) 與 npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
