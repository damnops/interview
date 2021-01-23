FROM php:8.0-apache

# Setup php ext pdo_mysql
RUN docker-php-ext-install pdo_mysql

ARG GIT_HASH
ARG TAG_TIME

ENV GIT_HASH=$GIT_HASH
ENV TAG_TIME=$TAG_TIME
ENV APP_DIR=/app

WORKDIR ${APP_DIR}

COPY entrypoint ${APP_DIR}
COPY src ${APP_DIR}/src
COPY apache/ /etc/apache2/sites-enabled/

# VOLUME ${APP_DIR}

ENTRYPOINT ["/app/entrypoint"]

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
