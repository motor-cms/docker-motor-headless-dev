# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based PHP 8.3-FPM development environment for Motor Headless CMS, a Laravel application. The container is designed for headless CMS development with extensive image/media processing capabilities.

## Architecture

**Docker Image Structure:**
- Base: `php:8.3-fpm`
- Primary purpose: Development environment for Motor Headless CMS (Laravel-based)
- Multi-platform support: linux/amd64 and linux/arm64
- Published to Docker Hub as `motorcms/motor-headless-php-83-dev`

**Key Components:**
- PHP-FPM with supervisor and cron services
- Laravel framework (L11) with standard artisan commands
- Image processing stack: ImageMagick (imagick), FFmpeg, GD with WebP support
- Image optimization tools: jpegoptim, optipng, pngquant, gifsicle, libavif
- PDF processing: pdftk-java
- Redis support for caching/queues
- Xdebug for development debugging

**Container Initialization (entrypoint.sh):**
The container bootstraps a Laravel application on startup:
1. Clears Laravel cache files
2. Copies `.env.example` to `.env`
3. Runs composer update using `composer-dev.json`
4. Starts supervisor and cron services
5. Generates application key and creates storage symlink
6. Clears all Laravel caches (config, route, view)
7. Starts PHP-FPM in background

## Development Commands

**Building the Docker Image:**
```bash
# Multi-platform build and push to Docker Hub
docker buildx build --builder my-builder --platform linux/amd64,linux/arm64 . -t motorcms/motor-headless-php-83-dev:2.0.0 --push
```

Note: The GitHub Actions workflow (`.github/workflows/docker-hub.yml`) automatically builds and pushes images on tag pushes (semantic versioning pattern `*.*.*`).

**Working with the Container:**
- The container expects a Laravel application to be mounted at `/var/www`
- Composer dependencies are managed via `composer-dev.json` instead of the standard `composer.json`
- The application requires a `.env.example` file to initialize

## Important Notes

- This is a **development image only** - includes Xdebug and development tooling
- The entrypoint assumes Laravel project structure and will fail without proper Laravel files
- Image includes comprehensive media processing capabilities for CMS operations
- Uses supervisor for service management (cron, PHP-FPM)
