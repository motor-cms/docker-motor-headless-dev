FROM php:8.3-fpm

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
    libxslt-dev \
    git \
    webp

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl xsl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Install imagick extension for php
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions imagick/imagick@master

#RUN cd /tmp
#RUN git clone https://github.com/Imagick/imagick.git
#RUN pecl install /tmp/imagick/package.xml
#RUN docker-php-ext-enable imagick

# Set working directory
WORKDIR /var/www

# define entrypoint
COPY ./entrypoint.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh

ENTRYPOINT /var/www/entrypoint.sh
