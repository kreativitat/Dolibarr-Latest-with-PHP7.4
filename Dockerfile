FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        zip \
        pdo_mysql \
        mysqli \
        intl \
        xml \
        curl \
        mbstring \
        opcache

# Set PHP configuration
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/dolibarr.ini \
    && echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/dolibarr.ini \
    && echo "post_max_size = 22M" >> /usr/local/etc/php/conf.d/dolibarr.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/dolibarr.ini \
    && echo "date.timezone = Europe/Lisbon" >> /usr/local/etc/php/conf.d/dolibarr.ini

# Download and install Dolibarr 21.0.1
ENV DOLI_VERSION 21.0.1
RUN wget -O dolibarr.zip "https://github.com/Dolibarr/dolibarr/archive/refs/tags/${DOLI_VERSION}.zip" \
    && unzip dolibarr.zip \
    && rm dolibarr.zip \
    && mv dolibarr-${DOLI_VERSION}/* /var/www/html/ \
    && mv dolibarr-${DOLI_VERSION}/.* /var/www/html/ 2>/dev/null || true \
    && rm -rf dolibarr-${DOLI_VERSION} \
    && rm -f /var/www/html/index.html

# Create required directories and set permissions
RUN mkdir -p /var/www/html/custom \
    && mkdir -p /var/www/documents \
    && chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/www/documents \
    && chmod -R 755 /var/www/html \
    && chmod -R 755 /var/www/documents

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 80
EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]