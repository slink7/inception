FROM debian:bullseye

RUN apt update -y && apt upgrade -y && \
    apt install -y nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

CMD [ "nginx", "-g", "daemon off;"]