# 1. Base image
FROM php:8.2-cli

# 2. Install system dependencies and PHP extensions
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        unzip \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        git \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo_mysql xml mbstring \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Set working directory
WORKDIR /app

# 5. Copy all code first
COPY . .

# 6. Copy .env.example to .env
RUN cp .env.example .env

# 7. Install dependencies
RUN composer install --no-dev --optimize-autoloader

# 8. Generate key & cache config
RUN php artisan key:generate --force && \
    php artisan config:cache && \
    php artisan migrate --force

# 9. Expose port & start server
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
