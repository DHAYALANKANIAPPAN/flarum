# Use the working PHP 8.3 baseline engine
FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    nginx \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxml2-dev \
    libzip-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql xml dom zip intl opcache

WORKDIR /var/www/html
COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/public/assets

# Overwrite the default Nginx config with your master file
COPY .nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# This replaces supervisor with your working execution command!
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
