# 1. Start from PHP CLI base image
FROM php:8.2-cli

# 2. Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libxml2-dev \
    && docker-php-ext-install \
    zip \
    pdo_mysql \
    xml \
    mbstring \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# 2.1 Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer
# 2.2 Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest
    

# 3. Ensure Composer binary is available
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Set work directory
WORKDIR /app

# 5. Copy only PHP dependency manifests first (leverage build cache)
COPY composer.json composer.lock ./

# 6. Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# 7. Copy all application code
COPY . .

# 8. Generate Laravel key & cache config
RUN php artisan key:generate \
  && php artisan config:cache

# 9. Expose port and define entrypoint
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
