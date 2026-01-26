NAME=inception

all:
	sudo docker compose -f srcs/docker-compose.yml up --build

down:
	sudo docker compose -f srcs/docker-compose.yml down

clean:
	sudo docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo docker system prune -af

re: fclean all
