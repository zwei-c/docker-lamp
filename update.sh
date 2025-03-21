#!/bin/bash

# 獲取projects資料夾下的所有專案

PROJECTS=$(ls ./projects)

# 讓使用者選擇要更新的專案

echo "🚀 選擇要更新的專案"
echo "------------------------------------------"
select PROJECT_NAME in $PROJECTS
do
    if [ -n "$PROJECT_NAME" ]; then
        break
    else
        echo "❌ 請選擇一個專案"
    fi
done

# 切換到專案目錄
cd "./projects/$PROJECT_NAME"

# 更新專案
echo "🚀 更新專案 $PROJECT_NAME"
echo "------------------------------------------"

git pull

echo "🚀 專案 $PROJECT_NAME 更新完成"

cd -

# 是否執行 composer install
read -p "是否執行 composer install? (y/n): " COMPOSER_INSTALL

if [ "$COMPOSER_INSTALL" = "y" ]; then

    read -p "請選擇php版本 (預設為8.3): " PHP_VERSION
    PHP_VERSION=${PHP_VERSION:-8.3}

    echo "🚀 執行 composer install"

    docker exec -it php$PHP_VERSION composer install --working-dir="/var/www/$PROJECT_NAME"

fi

# 是否執行資料庫遷移

read -p "是否執行資料庫遷移？(y/n): " MIGRATE_DB

if [ "$MIGRATE_DB" = "y" ]; then

    read -p "請選擇php版本 (預設為8.3): " PHP_VERSION
    PHP_VERSION=${PHP_VERSION:-8.3}

    echo "🚀 執行資料庫遷移"

    docker exec -it php$PHP_VERSION php /var/www/$PROJECT_NAME/artisan migrate --seed

fi

# 是否執行 npm install

read -p "是否執行 npm install? (y/n): " NPM_INSTALL

if [ "$NPM_INSTALL" = "y" ]; then

    echo "🚀 執行 npm install"

    docker exec -it node npm install --prefix "/var/www/$PROJECT_NAME"

fi

# 是否執行 npm run build

read -p "是否執行 npm run build? (y/n): " NPM_BUILD

if [ "$NPM_BUILD" = "y" ]; then

    echo "🚀 執行 npm run build"

    docker exec -it node npm run build --prefix "/var/www/$PROJECT_NAME"

fi

echo "🚀 專案 $PROJECT_NAME 更新完成"