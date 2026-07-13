FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    nginx \
    supervisor \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql gd zip intl opcache

WORKDIR /var/www/html

COPY . /var/www/html

COPY .nginx.conf /etc/nginx/http.d/flarum-locations.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/public/assets

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/var/www/html/docker/supervisord.conf"]
