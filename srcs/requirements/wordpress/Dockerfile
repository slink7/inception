FROM alpine:3.19

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-curl \
    php82-json \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-phar \
    php82-zip \
    wget \
    tar \
    bash \
	mariadb-client

RUN mkdir -p /var/www/html /run/php

RUN wget https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz \
 && mkdir -p /usr/src/wordpress/ \ 
 && mv wordpress/* /usr/src/wordpress/ \
 && rm -rf wordpress latest.tar.gz

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 9000

CMD ["/init.sh"]
