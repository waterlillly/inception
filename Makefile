COMPOSE = docker compose -f ./srcs/docker-compose.yml

GREEN = \033[0;32m
BLUE = \033[0;34m
MAGENTA = \033[0;35m
NC = \033[0m

all: up

up: 
	mkdir -p ~/data/wordpress
	mkdir -p ~/data/mariadb
	$(COMPOSE) up -d --build
	@echo "$(GREEN)All containers are up and running!$(NC)"

down:
	@echo "$(MAGENTA)Stopping containers...$(NC)"
	$(COMPOSE) down

clean:
	@echo "$(MAGENTA)Cleaning up containers and volumes...$(NC)"
	$(COMPOSE) down -v
	sudo rm -rf ~/data

fclean: clean
	@echo "$(BLUE)Complete cleanup - removing all Docker data...$(NC)"
	docker system prune -af
	docker volume prune -f

re: fclean up

.PHONY: all up down clean fclean re