# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based PHP 8.4-FPM development environment for Motor Headless CMS, a Laravel application. The container is designed for headless CMS development with extensive image/media processing capabilities.

## Architecture

**Docker Image Structure:**
- Base: `php:8.4-fpm`
- Primary purpose: Development environment for Motor Headless CMS (Laravel-based)
- Multi-platform support: linux/amd64 and linux/arm64
- Published to Docker Hub as `motorcms/motor-headless-php-83-dev` (note: image name retained for compatibility despite PHP 8.4 upgrade)
- Alternative Dockerfiles: `Dockerfile.alpine` and `Dockerfile.optimized` for specialized builds

**Key Components:**
- PHP-FPM with supervisor and cron services
- Laravel framework (L11) with standard artisan commands
- Image processing stack: ImageMagick (imagick), FFmpeg, GD with WebP support
- Image optimization tools: jpegoptim, optipng, pngquant, gifsicle, libavif, webp
- PDF processing: pdftk-java
- Redis support for caching/queues
- Xdebug for development debugging
- jq for JSON processing

**PHP Extensions Installed:**
- Database: pdo_mysql, mysqli
- String/Text: mbstring, intl
- Image: gd (with freetype, jpeg, webp), imagick
- File: zip, exif
- Process: pcntl
- Math: bcmath
- Web Services: soap, xsl
- Cache: redis

**Container Initialization (entrypoint.sh):**
The container bootstraps a Laravel application on startup:
1. Clears Laravel cache files (`rm bootstrap/cache/*.php`)
2. Copies `.env.example` to `.env`
3. Runs `COMPOSER=composer-dev.json composer update --no-scripts`
4. Starts supervisor and cron services
5. Generates application key (`php artisan key:generate`)
6. Creates storage symlink (`php artisan storage:link`)
7. Clears all Laravel caches (config, route, view)
8. Starts PHP-FPM in background and tails /dev/null to keep container running

## Development Commands

**Building the Docker Image:**
```bash
# Multi-platform build and push to Docker Hub (using build.txt command)
docker buildx build --builder my-builder --platform linux/amd64,linux/arm64 . -t motorcms/motor-headless-php-83-dev:2.0.0 --push

# Build without pushing (local testing)
docker build -t motorcms/motor-headless-php-83-dev:local .
```

**Automated Builds:**
- GitHub Actions workflow (`.github/workflows/docker-hub.yml`) automatically builds and pushes images on:
  - Tag pushes matching semantic versioning pattern `*.*.*`
  - Manual workflow dispatch
- **Note:** The workflow configuration currently references an outdated image name (`motorcms/motor-headless-php-81-dev`) that should be updated to match current naming

**Working with the Container:**
- Mount Laravel application at `/var/www`
- Requires `composer-dev.json` (not standard `composer.json`) for dependency management
- Requires `.env.example` file in Laravel root for initialization
- Container entrypoint automatically bootstraps Laravel on startup

## Important Notes

- **Development image only** - includes Xdebug and development tooling, not production-ready
- Entrypoint script assumes complete Laravel project structure and will fail without:
  - `bootstrap/cache/` directory
  - `.env.example` file
  - `composer-dev.json` file
- Comprehensive media processing capabilities for CMS operations (images, video, PDFs)
- Uses supervisor for process management (cron, PHP-FPM)
- Container runs indefinitely via `tail -f /dev/null` after initialization
