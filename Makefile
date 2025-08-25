COMPOSE = docker compose -f ./srcs/docker-compose.yml --env-file ./srcs/.env
DATA_DIR = /home/$(USER)/data

GREEN = \033[0;32m
BLUE = \033[0;34m
MAGENTA = \033[0;35m
NC = \033[0m

all: up

up: 
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb
	$(COMPOSE) up -d --build
	@echo "$(GREEN)Project is running! Go to https://$(shell grep DOMAIN_NAME srcs/.env | cut -d'=' -f2)$(NC)"

down:
	@echo "$(MAGENTA)Stopping containers...$(NC)"
	$(COMPOSE) down

clean:
	@echo "$(MAGENTA)Cleaning up containers and volumes...$(NC)"
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_DIR)

fclean: clean
	@echo "$(BLUE)Complete cleanup - removing all Docker data...$(NC)"
	docker system prune -af
	docker volume prune -f

re: fclean up

.PHONY: all up down clean fclean re