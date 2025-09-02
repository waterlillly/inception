# TO-DO / QUESTIONS
- checklist for eval/pushing
- what's what - a dictionary for keywords
- write down project flow (start-middle-end)
<!-- - minimize everything -->

- personalize wordpress -> make php website!
<!-- - cheatsheet for adding secrets -->
<!-- - cheatsheet for adding .env variables -->
<!-- - delete secrets -->
<!-- - rewrite Makefile -->
<!-- - check penultimate Debian version -->
<!-- - update .env.example -->
<!-- - check if --no-install-recommends works or should be taken out again -->
<!-- - check wordpress Dockerfile installed commands -> actually used? -->
<!-- - what happens if i do make up twice? (makefile relink?) -->
<!-- - is it even possible to use docker without a deamon? -->
<!-- - do i actually need apt-get upgrade? -->
<!-- - .yml file: name: ? needed? -->
<!-- - ${VAR:?error} -->
<!-- - use healthcheck? -->
<!-- - what is buildkit??? -->
<!-- - change LOGIN back to lbaumeis -->
<!-- - should .gitignore and .dockerignore be pushed to/ shown on github?? -->
- uncomment .md in gitignore file for eval
- delete stuff inside .gitkeep file
- add .gitignore to .gitignore and .dockerignore to .dockerignore??
- create .README (push to github but then add to .gitignore for eval!)
<!-- - add exec -->
<!-- - add theme to wordpress to enable comments -->
- how to login to mariadb + verify its not empty
<!-- - check if deleting data dir on host is actually valid! -->

- delete builtkit -> should be good with just using the newer docker compose version
<!-- - took out security headers in nginx, read more about them before adding -->
<!-- - DB_DATA_DIR -> is this even used? -->
- how do i stop makefile from printing out the commands?
<!-- - check if wordpress theme even gets used the way its inside now -->
<!-- - do i need ::443 and 443 ? -->
<!-- - change www.conf to wordpress.conf -->
___________________________________________________________________________________________________

# DICTIONARY
- docker
- docker-compose.yml
- dockerfile
- container
- image
- services:
	- nginx
	- wordpress
	- mariadb
- secrets
- environment
- dockerignore & gitignore
- ssl & self-signed certificates
- PID 1 & docker daemon
___________________________________________________________________________________________________

# FIRST TIME AWAY FROM HOME
- create secrets (db_root_password, db_user_password, wp_admin_password, wp_user_password)
- substitute .env.example with own .env () + create wordflow/cheatsheet for it
- add .gitignore
- add .dockerignore
- setup VM
___________________________________________________________________________________________________

## CHEATSHEET SECRETS
### option 1:
	*[ echo "mypassword" | docker secret create my_password - ]*
		-> - is used for reading from stdin

	in .yml file:
		secrets:
		my_password:
			external: true
		-> tells Docker that secret has already been created (+automatically mounted)

### option 2: -> prob use this version
	*[ echo "mypassword" > ./secrets/my_password.txt ]*
		-> manually create password file

	in .yml file: 
		secrets:
		my_password:
			file: ./../secrets/my_password.txt
		-> Docker looks for the file path and then creates the secret
		-> managed by Docker but tied to this compose project specifically, can't reuse outside
___________________________________________________________________________________________________

## CHEATSHEET ENV VARIABLES
TODO: todo!
___________________________________________________________________________________________________

## .GITIGNORE
	# Secrets (just files, keeps directory) 
	secrets/*.txt
	*.secret
	*.key
	*.crt
	*.pem

	# Environment files with real credentials
	.env
	*.env.local
	*.env.production

	# User-specific data
	/home/*/data/

	# Docker volumes and build cache
	.docker/
	docker-compose.override.yml

	# Other files
	.vscode/
	inception.pdf
	# *.md
	.idea/
	*.swp
	*.swo
	*~

	# OS generated files
	.DS_Store
	.DS_Store?
	._*
	Thumbs.db

	# Logs
	*.log
	logs/

	# Temporary files
	*.tmp
	*.temp

	# Backup files
	*.bak
	*.backup
___________________________________________________________________________________________________

## .DOCKERIGNORE
	# Version control
	.git
	.gitignore

	# Documentation
	README.md
	*.md

	# Development files
	.vscode/
	.idea/

	# OS files
	.DS_Store
	Thumbs.db

	# Temporary files
	*.log
	*.tmp
___________________________________________________________________________________________________

## SETTING UP THE VIRTUAL MACHINE
	- On 42 sgoinfre drive: Via Oracle VirtualBox install Virtual machine running Debian (Bookworm)
		- create user lbaumeis (pw doesnt matter)
		- allocate ~30 GB HD
		- keep dynamic disk size, so that you dont need to format all 30 GB at point of installation

	- set the resolution in the vm to same as school monitor (1920x1080) + run vm in fullscreen (ctrl + f)

	- add lbaumeis to sudo:
		su -
		usermod -aG sudo lbaumeis
		reboot

	- install zsh, oh-my-zsh, curl, git, google chrome (firefox instead?), vim

	- log into google account to sync bookmarks

	- create an sshkey via ssh-keygen and add it to your github (so you can pull inception repo)

	- install vscode, make, docker, docker-compose

	- add lbaumeis to docker group (so docker can be executed without sudo):
		sudo usermod -aG docker lbaumeis
		reboot

	- start vscode and log into github account to sync extensions

	- make domain point to localhost:
		sudo vim /etc/hosts
		add 127.0.0.1	lbaumeis.42.fr

	- create folders for persistent container data (on host machine):
		mkdir -p /home/lbaumeis/data/mariadb
		mkdir -p /home/lbaumeis/data/wordpress

	- give wordpress folder the rights to be accessed by nginx and wordpress (both use the www-data user)
		sudo chown -R www-data:www-data /home/lbaumeis/data/wordpress
		sudo chmod -R 755 /home/lbaumeis/data/wordpress

	- permanently enable buildkit:
		echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
		echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> ~/.bashrc
		export DOCKER_BUILDKIT=1
		export COMPOSE_DOCKER_CLI_BUILD=1

		sudo apt-get update
		sudo apt-get install docker-buildx-plugin

		in /etc/docker/daemon.json:
		{
			"features": {
				"buildkit": true
			}
		}

		then restart docker:
		sudo systemvtl restart docker

___________________________________________________________________________________________________

## .ENV
	# GENERAL
	LOGIN=lbaumeis
	DOMAIN_NAME=lbaumeis.42.fr
	COMPOSE_PROJECT_NAME=inception

	# NGINX
	SSL_CERT_FILE=/etc/ssl/certs/nginx-selfsigned.crt
	SSL_KEY_FILE=/etc/ssl/private/nginx-selfsigned.key

	# WORDPRESS
	WP_TITLE=Docker Playground Inception
	WP_ADMIN_USER=lionking
	WP_ADMIN_EMAIL=lionking@student.42vienna.com
	WP_USER=wpuserino
	WP_USER_EMAIL=lbaumeis@student.42vienna.com

	# DATABASE (MARIADB)
	DB_NAME=wordpress
	DB_HOST=mariadb:3306
	DB_USER=internalconnectuser
___________________________________________________________________________________________________

## to make nginx content reachable through custom domain:
	- edit /etc/hosts file on host machine, add  127.0.0.1 lbaumeis.42.fr
	- edit /etc/nginx/nginx.conf in container, add server lbaumeis.42.fr;
___________________________________________________________________________________________________

# PID 1
	On any Unix/Linux system, the very first process that starts is assigned PID 1 (normally this would be init or systemd)
	-> jobs: reap zombie processes (exited but not waited for) and forward signals (sigterm, sigint, etc) to child processes

	in docker container:
		-> PID 1 = what has been specified by CMD or ENTRYPOINT
		-> doesn't automatically do the jobs
		eg. nginx -g "daemon on":
			- nginx forks into background
			- foreground process (PID 1) exits immediately
			- docker sees container as finished -> shuts it down
			- by hacking around it, chances are there won't be a proper PID 1 for handling signals/zombies
		
		"daemon off":
			- nginx stays in foreground
			- nginx master process becomes PID 1
			- docker is able to:
							- deliver sigterm on docker stop
							- track logs
							- keep one main process (clean&predictable)
___________________________________________________________________________________________________

# IMPORTANT DOCKER COMPOSE COMMANDS
## *docker-compose up [-d]*
	This command starts all the services defined in your docker-compose.yml file. It creates the necessary containers, networks, and volumes if they don’t already exist. You can run it in the background by adding the -d option.

## *docker-compose down [-v]*
	Use this command to stop and remove all the containers and networks that were created by docker-compose up. It’s a good way to clean up resources when you no longer need the application running. Add -v to also remove the volumes.

## *docker-compose ps*
	This command lists all the containers associated with your Compose application, showing their current status and other helpful information. It’s great for monitoring which services are up and running.

## *docker-compose logs [<service_name>]*
	This command lets you view the logs generated by your services. If you want to focus on a specific service, you can specify its name to filter the logs, which is useful for troubleshooting.

## *docker-compose exec [db psql -U user -d mydb]*
	With this command, you can run a command inside one of the running service containers. It’s particularly useful for debugging or interacting with your services directly.

## *docker-compose build [--no-cache]*
	This command builds or rebuilds the images specified in your docker-compose.yml file. It’s handy when you’ve made changes to your Dockerfiles or want to update your images. Add --no-cache at the end to completely rebuild from scratch.

## *docker-compose pull*
	Use this command to pull the latest images for your services from their respective registries. It ensures that you have the most current versions before starting your application.

## *docker-compose start*
	This command starts containers that are already defined in your Compose file without recreating them. It’s a quick way to get your services running again after they’ve been stopped.

## *docker-compose stop*
	This command stops the running containers but keeps them intact, so you can start them up again later using docker-compose start.

## *docker-compose config*
	This command validates and displays the configuration from your docker-compose.yml file. It’s a useful way to check for any errors before you deploy your application.
___________________________________________________________________________________________________

# EVALUATION
## Introduction
	Please comply with the following rules:

	- Remain polite, courteous, respectful and constructive throughout the
	evaluation process. The well-being of the community depends on it.

	- Identify with the student or group whose work is evaluated the possible
	dysfunctions in their project. Take the time to discuss and debate the
	problems that may have been identified.

	- You must consider that there might be some differences in how your peers
	might have understood the project's instructions and the scope of its
	functionalities. Always keep an open mind and grade them as honestly as
	possible. The pedagogy is useful only and only if the peer-evaluation is
	done seriously.

## Guidelines
	- Only grade the work that was turned in the Git repository of the evaluated
	student or group.

	- Double-check that the Git repository belongs to the student(s). Ensure that
	the project is the one expected. Also, check that 'git clone' is used in an
	empty folder.

	- Check carefully that no malicious aliases was used to fool you and make you
	evaluate something that is not the content of the official repository.

	- To avoid any surprises and if applicable, review together any scripts used
	to facilitate the grading (scripts for testing or automation).

	- If you have not completed the assignment you are going to evaluate, you have
	to read the entire subject prior to starting the evaluation process.

	- Use the available flags to report an empty repository, a non-functioning
	program, a Norm error, cheating, and so forth.
	In these cases, the evaluation process ends and the final grade is 0,
	or -42 in case of cheating. However, except for cheating, student are
	strongly encouraged to review together the work that was turned in, in order
	to identify any mistakes that shouldn't be repeated in the future.

## Preliminary tests
	- Any credentials, API keys, environment variables must be set inside a .env file during the evaluation.
	In case any credentials, API keys are available in the git repository and outside of the .env file created during the evaluation, the evaluation stop and the mark is 0.
	Defense can only happen if the evaluated student or group is present. This way everybody learns by sharing knowledge with each other.
	If no work has been submitted (or wrong files, wrong directory, or wrong filenames), the grade is 0, and the evaluation process ends.
	For this project, you have to clone their Git repository on their station.

## General instructions
	For the entire evaluation process, if you don't know how to check a requirement, or verify anything, the evaluated student has to help you.
	- Ensure that all the files required to configure the application are located inside a srcs folder. The srcs folder must be located at the root of the repository.
	- Ensure that a Makefile is located at the root of the repository.
	TODO: Before starting the evaluation, run this command in the terminal:
	"docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null"
	- Read the docker-compose.yml file. There musn't be 'network: host' in it or 'links:'. Otherwise, the evaluation ends now.
	TODO: Read the docker-compose.yml file. There must be 'network(s)' in it. Otherwise, the evaluation ends now.
	- Examine the Makefile and all the scripts in which Docker is used. There musn't be '--link' in any of them. Otherwise, the evaluation ends now.
	- Examine the Dockerfiles. If you see 'tail -f' or any command run in background in any of them in the ENTRYPOINT section, the evaluation ends now. Same thing if 'bash' or 'sh' are used but not for running a script (e.g, 'nginx & bash' or 'bash').
	TODO: If the entrypoint is a script (e.g., ENTRYPOINT ["sh", "my_entrypoint.sh"], ENTRYPOINT ["bash", "my_entrypoint.sh"]), ensure it runs no program
	in background (e.g, 'nginx & bash').
	- Examine all the scripts in the repository. Ensure none of them runs an infinite loop.
	- The following are a few examples of prohibited commands: 'sleep infinity', 'tail -f /dev/null', 'tail -f /dev/random'
	- Run the Makefile.

## Mandatory part
	This project consists in setting up a small infrastructure composed of different services using docker compose. Ensure that all the following points are correct.

## Project overview
	The evaluated person has to explain to you in simple terms:
	- TODO: How Docker and docker compose work
	- TODO: The difference between a Docker image used with docker compose and without docker compose
	- TODO: The benefit of Docker compared to VMs
	- TODO: The pertinence of the directory structure required for this project (an example is provided in the subject's PDF file).

## Simple setup
	- Ensure that NGINX can be accessed by port 443 only. Once done, open the page.
	- Ensure that a SSL/TLS certificate is used.
	- Ensure that the WordPress website is properly installed and configured (you shouldn't see the WordPress Installation page).
	To access it, open https://login.42.fr in your browser, where login is the login of the evaluated student.
	- You shouldn't be able to access the site via http://login.42.fr.
	If something doesn't work as expected, the evaluation process ends now.

## Docker Basics
	- Start by checking the Dockerfiles.
	There must be one Dockerfile per service. Ensure that the Dockerfiles are not empty files.
	If it's not the case or if a Dockerfile is missing, the evaluation process ends now.
	- Make sure the evaluated student has written their own Dockerfiles and built their own Docker images.
	Indeed, it is forbidden to use ready-made ones or to use services such as DockerHub.
	- Ensure that every container is built from the penultimate stable version of Alpine/Debian.
	If a Dockerfile does not start with 'FROM alpine:X.X.X' or 'FROM debian:XXXXX', or any other local image, the evaluation process ends now.
	TODO: The Docker images must have the same name as their corresponding service. Otherwise, the evaluation process ends now.
	- Ensure that the Makefile has set up all the services via docker compose. This means that the containers must have been built using docker compose and that no crash happened.
	Otherwise, the evaluation process ends.

## Docker Network
	TODO: Ensure that docker-network is used by checking the docker-compose.yml file.
	- Then run the 'docker network ls' command to verify that a network is visible.
	TODO: The evaluated student has to give you a simple explanation of docker-network.
	If any of the above points is not correct, the evaluation process ends now.

## NGINX with SSL/TLS
	- Ensure that there is a Dockerfile.
	- Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
	- Try to access the service via http (port 80) and verify that you cannot connect.
	- Open https://login.42.fr/ in your browser, where login is the login of the evaluated student. The displayed page must be the configured WordPress website (you shouldn't see the WordPress Installation page).
	- The use of a TLS v1.2/v1.3 certificate is mandatory and must be demonstrated.
	The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear.
	If any of the above points is not clearly explained and correct, the evaluation process ends now.

## WordPress with php-fpm and its volume
	- Ensure that there is a Dockerfile.
	- Ensure that there is no NGINX in the Dockerfile.
	- Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
	- Ensure that there is a Volume.
	To do so: Run the command 'docker volume ls' then 'docker volume inspect <volume name>'.
	Verify that the result in the standard output contains the path '/home/login/data/', where login is the login of the evaluated student.
	TODO: Ensure that you can add a comment using the available WordPress user.
	- Sign in with the administrator account to access the Administration dashboard. The Admin username must not include 'admin' or 'Admin' (e.g., admin, administrator, Admin-login, admin-123, and so forth).
	- From the Administration dashboard, edit a page. Verify on the website that the page has been updated.
	If any of the above points is not correct, the evaluation process ends now.

## MariaDB and its volume
	- Ensure that there is a Dockerfile.
	- Ensure that there is no NGINX in the Dockerfile.
	- Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
	- Ensure that there is a Volume.
	To do so: Run the command 'docker volume ls' then 'docker volume inspect <volume name>'.
	Verify that the result in the standard output contains the path '/home/login/data/', where login is the login of the evaluated student.
	TODO: The evaluated student must be able to explain you how to login into the database.
	- Verify that the database is not empty.
	If any of the above points is not correct, the evaluation process ends now.

## Persistence!
	This part is pretty straightforward.
	- You have to reboot the virtual machine.
	- Once it has restarted, launch docker compose again.
	- Then, verify that everything is functional, and that both WordPress and MariaDB are configured. The changes you made previously to the WordPress website should still be here.
	If any of the above points is not correct, the evaluation process ends now.

___________________________________________________________________________________________________

# WORDPRESS CUSTOMIZATION
<!-- wp:group {"className":"is-style-default","style":{"spacing":{"padding":{"top":"var:preset|spacing|20","bottom":"var:preset|spacing|20","left":"var:preset|spacing|60","right":"var:preset|spacing|60"},"blockGap":"0"}},"backgroundColor":"base","layout":{"type":"flex","orientation":"vertical","justifyContent":"stretch","verticalAlignment":"center"}} -->
<div class="wp-block-group is-style-default has-base-background-color has-background" style="padding-top:var(--wp--preset--spacing--20);padding-right:var(--wp--preset--spacing--60);padding-bottom:var(--wp--preset--spacing--20);padding-left:var(--wp--preset--spacing--60)"><!-- wp:template-part {"slug":"header","theme":"twentytwentyfive","area":"header"} /-->

<!-- wp:query {"queryId":31,"query":{"perPage":3,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","author":"","search":"","exclude":[],"sticky":"","inherit":false},"metadata":{"categories":["posts"],"patternName":"core/fullwidth-posts-with-uppercase-titles","name":"Fullwidth posts with uppercase titles"},"align":"full","layout":{"type":"default"}} -->
<div class="wp-block-query alignfull"><!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"0","right":"0","bottom":"0","left":"0"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group alignfull" style="padding-top:0;padding-right:0;padding-bottom:0;padding-left:0"><!-- wp:post-template {"style":{"typography":{"textTransform":"none"}},"layout":{"type":"default"}} -->
<!-- wp:group {"style":{"spacing":{"padding":{"top":"16px","right":"16px","bottom":"16px","left":"16px"}}},"layout":{"type":"flex","flexWrap":"nowrap","justifyContent":"space-between"}} -->
<div class="wp-block-group" style="padding-top:16px;padding-right:16px;padding-bottom:16px;padding-left:16px"><!-- wp:post-terms {"term":"category","textAlign":"left"} /-->

<!-- wp:post-date /--></div>
<!-- /wp:group -->

<!-- wp:group {"className":"is-style-default","style":{"spacing":{"padding":{"top":"16px","bottom":"var:preset|spacing|70","right":"16px","left":"16px"}}},"layout":{"type":"default"}} -->
<div class="wp-block-group is-style-default" style="padding-top:16px;padding-right:16px;padding-bottom:var(--wp--preset--spacing--70);padding-left:16px"><!-- wp:heading -->
<h2 class="wp-block-heading">blog post 001</h2>
<!-- /wp:heading -->

<!-- wp:quote {"textAlign":"left"} -->
<blockquote class="wp-block-quote has-text-align-left"><!-- wp:paragraph -->
<p>First blog entry woop woop</p>
<!-- /wp:paragraph --></blockquote>
<!-- /wp:quote --></div>
<!-- /wp:group -->

<!-- wp:comments -->
<div class="wp-block-comments"><!-- wp:comments-title {"style":{"elements":{"link":{"color":{"text":"var:preset|color|contrast"}}},"typography":{"fontSize":"1.4rem"}},"textColor":"contrast"} /-->

<!-- wp:comment-template -->
<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"40px"} -->
<div class="wp-block-column" style="flex-basis:40px"><!-- wp:avatar {"size":39,"style":{"border":{"radius":"20px"}}} /--></div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:comment-author-name {"fontSize":"small"} /-->

<!-- wp:group {"style":{"spacing":{"margin":{"top":"0px","bottom":"0px"}}},"layout":{"type":"flex"}} -->
<div class="wp-block-group" style="margin-top:0px;margin-bottom:0px"><!-- wp:comment-date {"fontSize":"small"} /-->

<!-- wp:comment-edit-link {"fontSize":"small"} /--></div>
<!-- /wp:group -->

<!-- wp:comment-content /-->

<!-- wp:comment-reply-link {"fontSize":"small"} /--></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->
<!-- /wp:comment-template -->

<!-- wp:comments-pagination {"layout":{"type":"flex","justifyContent":"space-between"}} -->
<!-- wp:comments-pagination-previous {"style":{"typography":{"fontSize":"1.1rem"}}} /-->

<!-- wp:comments-pagination-next {"style":{"typography":{"fontSize":"1.1rem"}}} /-->
<!-- /wp:comments-pagination -->

<!-- wp:post-comments-form {"style":{"spacing":{"padding":{"right":"var:preset|spacing|30","left":"var:preset|spacing|30"}}}} /--></div>
<!-- /wp:comments -->
<!-- /wp:post-template --></div>
<!-- /wp:group --></div>
<!-- /wp:query -->

<!-- wp:template-part {"slug":"footer","theme":"twentytwentyfive"} /--></div>
<!-- /wp:group -->
