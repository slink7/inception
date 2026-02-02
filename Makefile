NAME=inception

all:
	sudo sh set_domain_name.sh
	sudo docker compose -f srcs/docker-compose.yml up --build

down:
	sudo docker compose -f srcs/docker-compose.yml down

clean:
	sudo docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo docker system prune -af

rmsite:
	sudo rm -rf /home/scambier/data/site/*

rmdatabase:
	sudo rm -rf /home/scambier/data/database/*

re: fclean all
