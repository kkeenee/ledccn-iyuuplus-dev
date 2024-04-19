# https://hub.docker.com/_/php
ARG PHP_CLI_VERSION=8.3-cli-alpine
# https://hub.docker.com/r/mlocati/php-extension-installer
ARG PHP_EXTENSION_INSTALL_VERSION=latest
# https://hub.docker.com/r/composer/composer
ARG COMPOSER_VERSION=latest

LABEL Maintainer="david <367013672@qq.com>" \
      Description="IYUUPlus-dev container with PHP ^8.3 based on Alpine Linux." \
      version="8.0"

# install-php-extensions
FROM mlocati/php-extension-installer:$PHP_EXTENSION_INSTALL_VERSION AS php-extension-installer
# composer
FROM composer/composer:$COMPOSER_VERSION AS composer

# 开始构建
FROM php:$PHP_CLI_VERSION

# 系统依赖安装
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN apk add --no-cache supervisor unzip

# PHP 扩展安装
# https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
RUN install-php-extensions \
    bcmath \
    curl \
    event \
    fileinfo \
    gd \
    mysqli \
    mbstring \
    pdo_mysql \
    opcache \
    pcntl \
    sockets \
    zip

# 设置配置文件
# php
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php.ini "$PHP_INI_DIR/conf.d/app.ini"
# supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 设置项目目录
RUN mkdir -p /app
WORKDIR /app

# 暴露端口
EXPOSE 8787
VOLUME ["/app"]
# 启动脚本
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
