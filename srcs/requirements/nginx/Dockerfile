FROM alpine:3.19

RUN apk add --no-cache nginx

COPY certs/ /etc/ssl/certs
COPY conf/default.conf /etc/nginx/http.d/default.conf

CMD ["nginx", "-g", "daemon off;"]

