#!/bin/bash

set -e

PROJECT_DIR="/var/www/html"

cd $PROJECT_DIR

echo "🎯 Setting up project..."
composer install --no-interaction --optimize-autoloader

if [ -f "artisan" ]; then
    echo "🔹 Running Laravel setup..."
    php artisan key:generate
    php artisan migrate --seed
fi

echo "✅ Setup complete!"
exec "$@"
