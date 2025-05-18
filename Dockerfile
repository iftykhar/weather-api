# 1. Start from PHP CLI with common build tools
FROM php:8.2-cli

# 2. Install system packages and PHP extensions Laravel needs
RUN apt-get update && apt-get install -y \
      unzip \                              # for Composer archive extraction :contentReference[oaicite:0]{index=0}
      libzip-dev \                         # for zip PHP extension
      libxml2-dev \                        # for xml PHP extension
    && docker-php-ext-install \
      zip \                                # ext-zip
      pdo_mysql \                          # ext-pdo_mysql
      xml \                                # ext-xml
      mbstring                             # ext-mbstring
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
