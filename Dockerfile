# ============================================================
# 小轩西游 (幻想西游复刻) Docker 镜像
# 基于 PHP 5.6 + Apache，兼容 mysql_* 扩展
# ============================================================
FROM hub.rat.dev/php:5.6-apache

# 标签信息
LABEL maintainer="xiyou-docker"
LABEL description="幻想西游 MMORPG 网页游戏 Docker 部署"

# Debian Stretch 已 EOL，切换到归档源
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-valid-until

# 安装系统依赖和 PHP 扩展
RUN apt-get update && apt-get install -y --allow-unauthenticated \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    wget \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd mysql mbstring zip bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 启用 Apache 模块
RUN a2enmod rewrite

# PHP 配置：适配老项目需求
RUN echo "date.timezone = Asia/Shanghai" >> /usr/local/etc/php/php.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/php.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT" >> /usr/local/etc/php/php.ini \
    && echo "upload_max_filesize = 20M" >> /usr/local/etc/php/php.ini \
    && echo "post_max_size = 20M" >> /usr/local/etc/php/php.ini \
    && echo "short_open_tag = On" >> /usr/local/etc/php/php.ini

# Apache 配置：允许 .htaccess 重写
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# 设置工作目录
WORKDIR /var/www/html

# 复制项目文件
COPY . /var/www/html/

# 复制入口脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 设置文件权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 暴露端口
EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
