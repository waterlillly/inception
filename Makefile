COMPOSE_FILE = ./srcs/docker-compose.yml
DC = docker compose -f $(COMPOSE_FILE)
ADD_HOST = 127.0.0.1\tlbaumeis.42.fr

# create volumes and add host to /etc/hosts if not present
prep:
	mkdir -p /home/$(USER)/data/wordpress /home/$(USER)/data/mariadb
	if ! grep -q "$(ADD_HOST)" /etc/hosts; then \
		sudo sh -c 'echo "$(ADD_HOST)" >> /etc/hosts'; \
	fi

build:
	$(DC) build --no-cache

# detached, full build, no cache
all: prep build
	$(DC) up -d

# build images only if non existent, then start in forground (shows logs)
up: prep
	$(DC) up

# same as 'up' but detached -> no logs
up-d: prep
	$(DC) up -d

down:
	$(DC) down

# stop containers, data safe
stop:
	$(DC) stop

# start stopped containers again
start:
	$(DC) start

# quickly restart containers (eg. after config change) 
restart:
	$(DC) restart

ps:
	$(DC) ps

logs:
	$(DC) logs

# stop and remove containers, networks and volumes (only project data!)
clean:
	$(DC) down -v
	sudo rm -rf /home/$(USER)/data/wordpress /home/$(USER)/data/mariadb

# wipes all Docker resources on the machine (containers, images, volumes, networks)
fclean: clean
	docker system prune -af --volumes

re: fclean all

.PHONY: prep build all up up-d down start stop restart ps logs clean fclean re












# all: build up

# build: check
# 	docker-compose -f $(COMPOSE_FILE) build

# up:
# 	docker-compose -f $(COMPOSE_FILE) up -d

# down:
# 	docker-compose -f $(COMPOSE_FILE) down

# restart:
# 	docker-compose -f $(COMPOSE_FILE) restart

# clean:
# 	sudo rm -rf ~/data/wordpress ~/data/mariadb
# 	docker-compose -f $(COMPOSE_FILE) down ##

# fclean:

# rmi:
# 	docker-compose -f $(COMPOSE_FILE) down --rmi all

# re: fclean all

# check:
# 	mkdir -p ~/data/wordpress ~/data/mariadb
# 	if [[ ! grep -q "$(ADD_HOST)" /etc/hosts ]]; then
# 		sudo sh -c 'echo "$(ADD_HOST)" >> /etc/hosts'
# 	fi

# .PHONY: all build up down restart clean fclean check