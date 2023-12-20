FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libgd-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    cron \
    imagemagick \
    ffmpeg \
    wget \
    gnupg \
    supervisor \
    htop \
    libmagickwand-dev \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    libavif-bin \
    libwebp-dev \
    webp

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Install imagick extension for php
RUN pecl install imagick && docker-php-ext-enable imagick

# Set working directory
WORKDIR /var/www

# Install depedencies, set .env file, migrate and start fpm server
CMD cp .env.example .env && COMPOSER=composer-dev.json composer update --no-scripts && php artisan key:generate && php artisan storage:link && php artisan config:clear && php artisan route:clear && php artisan view:clear && php-fpm
