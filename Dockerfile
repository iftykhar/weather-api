# 1. Use official PHP CLI image with necessary extensions
FROM php:8.2-cli

# 2. Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
      libzip-dev \
      unzip \
    && docker-php-ext-install zip pdo_mysql

# 3. Install Composer globally (copy from Composer’s official image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Set working directory inside container
WORKDIR /app

# 5. Copy composer files and install PHP dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# 6. Copy the rest of the application code
COPY . .

# 7. Generate app key and cache config
RUN php artisan key:generate \
    && php artisan config:cache

# 8. Expose the port your app runs on
EXPOSE 8000

# 9. Define the command to run your app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
