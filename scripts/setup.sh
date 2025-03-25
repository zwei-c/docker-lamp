#!/bin/bash

# 互動式專案設定腳本

read -p "輸入專案名稱 (如 project1): " PROJECT_NAME
PROJECT_DIR="../projects/$PROJECT_NAME"
echo "專案資料夾: $PROJECT_DIR"

# 檢查專案資料夾是否不存在
if [ ! -d "$PROJECT_DIR" ]; then
    echo "錯誤：專案資料夾不存在！"
    exit 1
fi

# 選擇專案類型
echo "選擇專案類型:"
select FRAMEWORK in "laravel" "ci3"; do
    case $FRAMEWORK in
        laravel | ci3) break ;;
        *) echo "請輸入有效選項。" ;;
    esac
done

# 選擇 PHP 版本
echo "選擇 PHP 版本:"
select PHP_VERSION in "7.3" "7.4" "8.0" "8.1" "8.3"; do
    case $PHP_VERSION in
        7.3 | 7.4 | 8.0 | 8.1 | 8.3) break ;;
        *) echo "請輸入有效選項。" ;;
    esac
done

PHP_CONTAINER="php${PHP_VERSION//./}"

# 產生 nginx conf
CONF_TEMPLATE="./templates/$FRAMEWORK.conf"
CONF_OUTPUT="../docker/nginx/conf.d/$PROJECT_NAME.conf"

sed -e "s/{domain}/$PROJECT_NAME.test/g" \
    -e "s/{project_name}/$PROJECT_NAME/g" \
    -e "s/{php_container}/$PHP_CONTAINER/g" \
    "$CONF_TEMPLATE" >"$CONF_OUTPUT"

# 建立 MySQL 資料庫
docker-compose exec -T mysql mysql -uroot -p123456 -e "CREATE DATABASE IF NOT EXISTS \`$PROJECT_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >/dev/null 2>&1

# 重載 nginx
docker-compose exec -T nginx nginx -s reload >/dev/null 2>&1

echo "專案設定完成，已建立資料庫並設定 Nginx。"
