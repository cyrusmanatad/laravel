FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nginx \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    intl \
    zip \
    exif \
    pcntl \
    bcmath \
    gd

# Install mbstring separately
RUN docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-install mbstring

# Copy custom PHP configuration
COPY server/php.ini /usr/local/etc/php/conf.d/custom.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Create necessary directories
RUN mkdir -p /var/www/html/writable/cache \
    && mkdir -p /var/www/html/writable/logs \
    && mkdir -p /var/www/html/writable/session \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/run/nginx

# Copy nginx configuration
COPY server/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the rest of the application
COPY . .

# Install dependencies
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/writable \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /var/run/nginx

# Expose correct port
EXPOSE 8080

# Copy and set permissions for the start script
COPY server/start.sh /start.sh
RUN chmod +x /start.sh

# Start Nginx and PHP-FPM
CMD ["/start.sh"]