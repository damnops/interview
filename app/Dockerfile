FROM php:8.0-apache

ENV APP_DIR=/app
ENV APACHE_LOG_DIR=/app/log
ARG GIT_HASH=xxxxxxx
ARG TAG_TIME=194910010000

RUN docker-php-ext-install pdo_mysql
# COPY apache/ /etc/apache2/sites-enabled/

WORKDIR ${APP_DIR}

COPY entrypoint .

VOLUME [ "${APP_DIR}" , "${APACHE_LOG_DIR}" ]

RUN for i in $(find ${APP_DIR} -type f -name '*.php'); do echo "<hr/>Build: ${GIT_HASH}@${TAG_TIME}<br/>" >> $i; done

EXPOSE 80

#ENTRYPOINT [ "/app/entrypoint" , "/usr/sbin/apache2 -DFOREGROUND" ]
CMD [ "/app/entrypoint" , "/usr/sbin/apache2 -DFOREGROUND" ]
#CMD /app/entrypoint

#CMD /usr/sbin/apache2 -DFOREGROUND
