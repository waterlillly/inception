COMPOSE_FILE = ./srcs/docker-compose.yml
DC = docker compose -f $(COMPOSE_FILE)
LOGIN := $(shell grep -E '^LOGIN=' srcs/.env 2>/dev/null | cut -d'=' -f2)

# BASICS
all: prep build up					# prepare volumes, build images, start containers

prep:								# create data-directories on host, if not present
	@mkdir -p /home/$(LOGIN)/data/wordpress
	@mkdir -p /home/$(LOGIN)/data/mariadb

build:								# build or update images
	$(DC) build

up:									# start in detached mode
	$(DC) up -d

down:								# stop and remove containers and networks
	$(DC) down

clean:								# stop and remove containers, networks and volumes
	$(DC) down -v

ps:									# show running containers
	$(DC) ps

re: clean all

.PHONY: all prep build up down clean ps re

# DEVELOPMENT
refresh: build up-d					# update images, then start in detached mode

rebuild:							# rebuild all images from scratch
	$(DC) build --no-cache

up-d:								# start (with logs)
	$(DC) up

logs-n:								# show nginx logs
	$(DC) logs nginx

logs-m:								# show mariadb logs
	$(DC) logs mariadb

logs-w:								# show wordpress logs
	$(DC) logs wordpress

exec:								# eg. SERVICE=mariadb CMD="mysql -u root -p" -> access mysql as root
	@if [ ! -z "$(SERVICE)" ] && [ ! -z "$(CMD)" ]; then \
		$(DC) exec $(SERVICE) $(CMD); \
	else \
		echo "Syntax: [ make exec SERVICE=<service> CMD=<command> ]"; \
	fi

.PHONY: refresh rebuild up-d logs-n logs-m logs-w exec

# OTHERS
start:								# start containers (eg. after stop)
	$(DC) start

stop:								# stop containers (eg. for changing config, not images)
	$(DC) stop

logs:								# show all logs
	$(DC) logs

images:								# show all images
	$(DC) images

rmi:								# remove all project images
	$(DC) rmi --all

prune:								# remove unused data (stopped containers, networks, dangling images and cache)
	docker system prune -af
# 									  -a: removes dangling + unused images (=all)
# 									  -f: skip confirmation
# 									  --volumes: removes unused volumes

fclean:								# wipe all Docker resources (images, containers, networks, volumes, data-dirs on host)
	@read -p "This will remove all data, including directories on host. Are you sure? [y/N]: " confirm && \
    if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(DC) down -v; \
		sudo rm -rf /home/$(LOGIN)/data/wordpress /home/$(LOGIN)/data/mariadb || true; \
		docker system prune -af --volumes; \
	else \
		echo "Cancelled"; \
		exit 1; \
	fi

.PHONY: start stop logs images rmi prune fclean