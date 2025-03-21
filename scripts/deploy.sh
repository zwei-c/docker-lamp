#!/bin/bash
set -e

echo "🚀 Laravel / CodeIgniter 部署工具"
echo "------------------------------------------"

# 讓使用者輸入專案名稱
read -p "請輸入專案名稱: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ 專案名稱不能為空"
    exit 1
fi

# 讓使用者輸入 Git Repo 地址
read -p "請輸入 Git Repo 地址 (SSH 格式): " GIT_REPO
if [ -z "$GIT_REPO" ]; then
    echo "❌ Git Repo 不能為空"
    exit 1
fi

# 讓使用者選擇 PHP 版本
echo "可選 PHP 版本: 7.3, 8.0, 8.3"
read -p "請輸入 PHP 版本 (預設 8.3): " PHP_VERSION
PHP_VERSION=${PHP_VERSION:-8.3}

# 讓使用者輸入 Domain
read -p "請輸入專案對應的 Domain (如 project.example.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "❌ Domain 不能為空"
    exit 1
fi

# 讓使用者輸入DB_HOST 不輸入則為預設的mysql
read -p "請輸入資料庫主機位置 (預設:mysql): " DB_HOST
DB_HOST=${DB_HOST:-mysql}

# 讓使用者輸入DB_USER 不輸入則為預設的root
read -p "請輸入資料庫使用者 (預設:root): " DB_USER
DB_USER=${DB_USER:-root}

# 讓使用者輸入DB_PASSWORD 不輸入則為空
read -p "請輸入資料庫密碼 (預設:G4!kR8@mN1#zQ5pL): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-'G4!kR8@mN1#zQ5pL'}


echo "------------------------------------------"
echo "🚀 專案設定完成，開始部署..."
echo "🔹 專案名稱: $PROJECT_NAME"
echo "🔹 Git Repo: $GIT_REPO"
echo "🔹 PHP 版本: $PHP_VERSION"
echo "🔹 Domain: $DOMAIN"
echo "🔹 資料庫主機: $DB_HOST"
echo "🔹 資料庫使用者: $DB_USER"
echo "🔹 資料庫密碼: $DB_PASSWORD"

echo "------------------------------------------"

# 定義專案目錄（存放原始專案碼）
PROJECT_DIR="./projects/$PROJECT_NAME"
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
fi

# Clone Git 專案或更新現有專案
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "📥 正在 Clone 專案..."
    git clone "$GIT_REPO" "$PROJECT_DIR"
else
    echo "🔄 專案已存在，執行 Git Pull..."
    cd "$PROJECT_DIR"
    git pull origin main
    cd -
fi

# 設定git分支
read -p "請輸入要部署的分支 (預設:main): " BRANCH

BRANCH=${BRANCH:-main}

cd "$PROJECT_DIR"

git checkout $BRANCH

cd -

# 自動偵測專案類型，設定 WEB_ROOT
if [ -f "$PROJECT_DIR/artisan" ]; then
    echo "📌 偵測到 Laravel 專案，設定 WEB_ROOT 為 'public'"
    WEB_ROOT="public"
else
    echo "📌 偵測到 CodeIgniter 專案，設定 WEB_ROOT 為 ''"
    WEB_ROOT=""
fi

# 設定 Nginx 虛擬主機設定檔

NGINX_CONFIG_FILE="./nginx/$PROJECT_NAME.conf"

if [ -f "$NGINX_CONFIG_FILE" ]; then
    echo "🔄 虛擬主機設定檔已存在，執行備份..."
    mv "$NGINX_CONFIG_FILE" "$NGINX_CONFIG_FILE.bak"
fi

echo "📝 正在產生 Nginx 虛擬主機設定檔..."

cat > "$NGINX_CONFIG_FILE" <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/html/$PROJECT_NAME/$WEB_ROOT;
    index index.php index.html index.htm;

    access_log /var/log/nginx/${PROJECT_NAME}_access.log;
    error_log /var/log/nginx/${PROJECT_NAME}_error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php$PHP_VERSION:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 載入 Nginx 設定檔

echo "🔄 載入 Nginx 設定檔..."

docker exec nginx_proxy nginx -s reload

# 建立資料表

echo "🚚 正在建立資料庫..."

docker exec -it mysql mysql -h $DB_HOST -u $DB_USER -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME;"

# 設定 相關設定檔與部屬

echo "📝 正在設定相關設定檔與部屬..."


if [ -f "$PROJECT_DIR/artisan" ]; then
    echo "📌 偵測到 Laravel 專案，設定 .env 檔案..."

    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"

    sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/g" "$PROJECT_DIR/.env"
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=$PROJECT_NAME/g" "$PROJECT_DIR/.env"
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/g" "$PROJECT_DIR/.env"
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=\"$DB_PASSWORD\"/g" "$PROJECT_DIR/.env"

    read -p "設定APP_ENV 為 1:development 2:production (1/2) 預設為 development: " APP_ENV
    if [ "$APP_ENV" = "2" ]; then
        sed -i "s/APP_ENV=.*/APP_ENV=production/g" "$PROJECT_DIR/.env"
    else
        sed -i "s/APP_ENV=.*/APP_ENV=development/g" "$PROJECT_DIR/.env"
    fi

    read -p "設定APP_DEBUG 為 1:true 2:false (1/2) 預設為 true: " APP_DEBUG
    if [ "$APP_DEBUG" = "2" ]; then
        sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/g" "$PROJECT_DIR/.env"
    else
        sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/g" "$PROJECT_DIR/.env"
    fi

    echo "🚚 正在安裝 Composer 套件..."
    docker exec -it php$PHP_VERSION composer install --working-dir=/var/www/html/$PROJECT_NAME
    echo "🚚 正在產生 Laravel 金鑰..."
    docker exec -it php$PHP_VERSION php /var/www/html/$PROJECT_NAME/artisan key:generate

    read -p "是否執行資料庫遷移？(y/n): " MIGRATE_DB
    if [ "$MIGRATE_DB" = "y" ]; then
        echo "🚚 正在執行資料庫遷移..."
        docker exec -it php$PHP_VERSION php /var/www/html/$PROJECT_NAME/artisan migrate --seed
    fi

    echo "🚚 正在執行 link storage"
    docker exec -it php$PHP_VERSION php /var/www/html/$PROJECT_NAME/artisan storage:link

    echo "🚚 正在執行 NPM 安裝與建置..."
    docker exec -it node npm install --prefix /var/www/html/$PROJECT_NAME

    read -p "是否執行前端建置？(y/n): " BUILD_FRONTEND
    if [ "$BUILD_FRONTEND" = "y" ]; then
        echo "🚚 正在執行前端建置..."
        docker exec -it node npm run build --prefix /var/www/html/$PROJECT_NAME
    fi

    chmod -R 777 "$PROJECT_DIR/storage"
    chmod -R 777 "$PROJECT_DIR/bootstrap/cache"

else
    echo "📌 偵測到 CodeIgniter 專案，設定 application/config/database.php..."

    cp database.php "$PROJECT_DIR/application/config/database.php"

    sed -i "s/'hostname' => 'localhost',/'hostname' => '$DB_HOST',/g" "$PROJECT_DIR/application/config/database.php"
    sed -i "s/'database' => 'database',/'database' => '$PROJECT_NAME',/g" "$PROJECT_DIR/application/config/database.php"
    sed -i "s/'username' => 'root',/'username' => '$DB_USER',/g" "$PROJECT_DIR/application/config/database.php"
    sed -i "s/'password' => '',/'password' => '$DB_PASSWORD',/g" "$PROJECT_DIR/application/config/database.php"

    echo "🚚 正在建立 uploads 與 captcha 目錄..."

    mkdir -p "$PROJECT_DIR/captcha"
    chmod -R 777 "$PROJECT_DIR/captcha"
    mkdir -p "$PROJECT_DIR/uploads"
    chmod -R 777 "$PROJECT_DIR/uploads"
fi

read -p "是否啟用 HTTPS？(y/n): " ENABLE_HTTPS

if [ "$ENABLE_HTTPS" = "y" ]; then
    echo "🔒 正在產生 SSL 憑證..."
    docker exec nginx_proxy certbot --nginx -d $DOMAIN
    
    if [ -f "$PROJECT_DIR/artisan" ]; then
        sed -i "s/APP_URL=.*/APP_URL=https:\/\/$DOMAIN/g" "$PROJECT_DIR/.env"
    else
        sed -i "s/\$config\['base_url'\] = '';/\$config\['base_url'\] = 'https:\/\/$DOMAIN';/g" "$PROJECT_DIR/application/config/config.php"
    fi
    
    echo "✅ 部署完成！請訪問 https://${DOMAIN}"


else

    if [ -f "$PROJECT_DIR/artisan" ]; then
        sed -i "s/APP_URL=.*/APP_URL=http:\/\/$DOMAIN/g" "$PROJECT_DIR/.env"
    else
        sed -i "s/\$config\['base_url'\] = '';/\$config\['base_url'\] = 'http:\/\/$DOMAIN';/g" "$PROJECT_DIR/application/config/config.php"
    fi

    echo "✅ 部署完成！請訪問 http://${DOMAIN}"
fi


