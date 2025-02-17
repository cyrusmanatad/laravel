#!/bin/bash

# Make sure nginx process can write to logs
chown -R www-data:www-data /var/log/nginx
chown -R www-data:www-data /var/run/nginx

# Start PHP-FPM
php-fpm &

# Start Nginx in foreground
nginx -g 'daemon off;'