COMPOSE_FILE = ./srcs/docker-compose.yml
DC = docker compose -f $(COMPOSE_FILE)

# Use LOGIN from srcs/.env at runtime for host data folders
LOGIN := $(shell grep -E '^LOGIN=' srcs/.env 2>/dev/null | cut -d'=' -f2)

# detached, full build
all: prep build
	$(DC) up -d

# create volumes and add host to /etc/hosts if not present
prep:
	@mkdir -p /home/$(LOGIN)/data/wordpress /home/$(LOGIN)/data/mariadb

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

# exec:
# 	$(DC) exec

# stop containers, data safe
stop:
	$(DC) stop

# start stopped containers again
start:
	$(DC) start

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

# prune overview
# docker system prune: removes unused data (stopped containers, unused networks, dangling images and build cache)
# flags:
# -a, --all: removes all unused images not just dangling ones
# -f, --force: skip confirmation
# --volumes: removes unused volumes
prune:
	docker system prune -af

# wipes all Docker resources on the machine (containers, images, volumes, networks)
# "|| true" -> ensures the Makefile doesnt stop if rm fails (e.g. if the path doesnt exist)
fclean: clean
	@read -p "Are you sure? [y/N]: " confirm && \
    if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		@rm -rf /home/$(LOGIN)/data/wordpress /home/$(LOGIN)/data/mariadb || true; \
		docker system prune -af --volumes; \
	else \
		echo "Cancelled"; \
		exit 1; \
	fi

re: fclean all

.PHONY: all prep build rebuild up up-d down start stop ps logs logs-n logs-m logs-w images clean prune fclean re