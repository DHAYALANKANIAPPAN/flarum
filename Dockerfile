# 1. Use the working PHP 8.3 baseline engine
FROM php:8.3-fpm-alpine

# 2. Install native Linux utilities and standard extensions required by Flarum
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

# 3. Create the web app directory inside the image
WORKDIR /var/www/html

# 4. Copy all your application code from GitHub into the container workspace
COPY . /var/www/html

# 5. Fix directory system permission tags so the webserver can write files
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/public/assets

# 6. Overwrite the default Nginx internal config with your master file
COPY .nginx.conf /etc/nginx/nginx.conf

# 7. Open up the web port
EXPOSE 80

# 8. Start the PHP engine in the background and Nginx in the foreground together
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
