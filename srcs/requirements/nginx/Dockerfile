FROM alpine:3.18

RUN apk add --no-cache nginx

COPY conf/default.conf /etc/nginx/http.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

