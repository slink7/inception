FROM alpine:3.19

RUN apk update && apk add --no-cache mariadb mariadb-client
RUN mkdir -p /run/mysqld \
 && chown -R mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/my.cnf
COPY tools/init.sh /init.sh

CMD ["/init.sh"]

