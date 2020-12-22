FROM php:8.0-apache

ENV APP_DIR=/app
ARG GIT_HASH=xxxxxxx
ARG TAG_TIME=194910010000

RUN docker-php-ext-install pdo_mysql
COPY apache/ /etc/apache2/sites-enabled/

WORKDIR ${APP_DIR}

COPY entrypoint .
COPY src src

VOLUME ${APP_DIR}

RUN for i in $(find ${APP_DIR} -type f -name '*.php'); do echo "<hr/>Build: ${GIT_HASH}@${TAG_TIME}<br/>" >> $i; done

ENTRYPOINT /app/entrypoint

CMD /usr/sbin/apache2 -DFOREGROUND
