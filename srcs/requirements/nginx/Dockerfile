FROM alpine:3.18

MAINTAINER scambier <scambier@student.42.fr>

RUN apk add --no-cache nginx

COPY certs/ /etc/ssl/certs
COPY conf/default.conf /etc/nginx/http.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

