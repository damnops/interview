FROM php:7.1-apache
MAINTAINER "Zhu Ye" <phoenix_zhu@outlook.com>

RUN docker-php-ext-install pdo_mysql
COPY apache/ /etc/apache2/sites-enabled/

WORKDIR /app

COPY entrypoint .
COPY src .

ENTRYPOINT ["/app/entrypoint"]
CMD ["/app/run"]