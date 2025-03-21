
art83="art83() {
    docker exec -it php8.3  php artisan \"\$1\" --working-dir=\"/var/www/html/\$2\"
}"


# 將 alias.sh 中定義的函數 加入到 ~/.bashrc

if [ -f ~/.bashrc ]; then
    echo "🚀 載入 ~/.bashrc"
    source ~/.bashrc
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi