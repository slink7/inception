
init:
	sudo systemctl enable docker

build_images:
	sudo docker build -t mariadb srcs/requirements/nginx/
	sudo docker build -t nginx srcs/requirements/mariadb/

destroy_images:
	sudo docker rmi mariadb
	sudo docker rmi nginx

run_containers:
	sudo docker run

stop_containers:
	sudo docker stop mariadb -d -p 3306:3306
	sudo docker stop nginx

remove_containers:
	sudo docker rm mariadb
	sudo docker rm nginx

up:
	sudo docker compose up --build
