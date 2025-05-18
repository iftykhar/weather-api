# 1. Base image
FROM php:8.2-cli

# 2. Install system dependencies and PHP extensions
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        unzip \
        libzip-dev \
        libxml2-dev \
        git \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo_mysql xml mbstring \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# 3. Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Set working directory
WORKDIR /app

# 5. Dependencies: copy manifests & install
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# 6. Copy all code
COPY . .

# 7. Generate key & cache config
RUN php artisan key:generate && php artisan config:cache

# 8. Expose port & start server
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
