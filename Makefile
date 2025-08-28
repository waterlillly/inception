COMPOSE_FILE = ./srcs/docker-compose.yml
DC = docker compose -f $(COMPOSE_FILE)
# ADD_HOST = 127.0.0.1 lbaumeis.42.fr TODO: change back!

# detached, full build
all: prep build
	$(DC) up -d

# create volumes and add host to /etc/hosts if not present TODO: change back!
prep:
	@if [ "$(USER)" = "lilly" -o "$(USER)" = "lbaumeis" ]; then \
		mkdir -p /home/$(USER)/data/wordpress /home/$(USER)/data/mariadb; \
	fi
# 	@if ! grep -q "127.0.0.1[[:space:]]lbaumeis.42.fr" /etc/hosts; then \
# 		sudo sh -c 'echo "$(ADD_HOST)" >> /etc/hosts'; \
# 	fi

# create or refresh images
build:
	$(DC) build

# force complete rebuild
rebuild:
	$(DC) build --no-cache

# build missing images, then start in forground (shows logs)
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

# show all logs
logs:
	$(DC) logs

# show nginx logs
logs-n:
	$(DC) logs nginx

# show mariadb logs
logs-m:
	$(DC) logs mariadb

# show wordpress logs
logs-w:
	$(DC) logs wordpress

# show all images built by this project
images:
	$(DC) images

# stop and remove containers, networks and volumes (only project data!)
clean:
	$(DC) down -v

# clean up unused docker resources (systemwide)
prune:
	docker system prune -af

# wipes all Docker resources on the machine (containers, images, volumes, networks)
fclean: clean
	@if [ "$(USER)" = "lilly" -o "$(USER)" = "lbaumeis" ]; then \
		sudo rm -rf /home/$(USER)/data/wordpress /home/$(USER)/data/mariadb; \
	fi
	docker system prune -af --volumes

re: fclean all

.PHONY: all prep build rebuild up up-d down start stop restart ps logs logs-n logs-m logs-w images clean prune fclean re

# prune overview
# docker system prune: removes unused data (stopped containers, unused networks, dangling images and build cache)
# flags:
# -a, --all: removes all unused images not just dangling ones
# -f, --force: skip confirmation
# --volumes: removes unused volumes