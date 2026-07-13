# 1. Use the required PHP 8.3 baseline with FPM engine built-in
FROM php:8.3-fpm-alpine

# 2. Install necessary system utilities and core PHP extensions required by Flarum
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libxml2-dev \
    libzip-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        xml \
        dom \
        zip \
        intl \
        opcache

# 3. Establish the operational deployment directory paths
WORKDIR /var/www/html

# 4. Copy the compiled distribution application codebase into place
COPY . /var/www/html

# 5. Fix directory system permission tags so the webserver can write files
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/public/assets

# 6. Apply custom Nginx and Supervisor configuration paths
COPY .nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7. Expose the external web listener port 
EXPOSE 80

# 8. Fire up the orchestration supervisor to run both Nginx and PHP simultaneously
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
