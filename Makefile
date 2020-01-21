HAS_MACHINE := $(shell [ -e /Applications/Docker.app/Contents/Resources/bin/docker ] && echo "0" || (hash docker-machine &>/dev/null && echo "1" || echo "0"))
ifeq ($(HAS_MACHINE), 1)
  IP:=$(shell docker-machine env docker-machine-dev >/dev/null 2>&1 && docker-machine ip docker-machine-dev || echo "")
else
  IP:=localhost
endif

ifeq ("$(shell uname)", "Darwin")
  IS_LINUX:=0
  OPEN=open
else
  IS_LINUX:=1
  OPEN=xdg-open
endif

include ../.env.example

.PHONY: help

help:
  @echo "General:"
	@echo
	@echo "  make help              Prints this help."
	@echo
	@echo "  make open              Open www in your browser."
	@echo "  make open-nginx        Open nginx in your browser."
	@echo "  make open-pma          Open phpmyadmin in your browser."
	@echo
	@echo "Docker:"
	@echo
	@echo "  make build             Build the docker containers."
	@echo "  make serve             Start async the docker containers."
	@echo "  make start             Start the docker containers."
	@echo "  make down              Down the docker containers."
	@echo "  make stop              Stop the docker containers."
	@echo "  make status            Status the docker containers."
	@echo "  make restart           Restart the docker containers."
	@echo
	@echo "  make shell             Shell in the docker containers."
	@echo "  make migrate           Migration in the docker containers."
	@echo "  make rollback          Migration rollback in the docker containers."
	@echo "  make routes            Check Laravel routing."
	@echo "  make composer-install  Composer install in the docker containers."
	@echo "  make composer          Command for composer. ex:) make composer CM='migrate'"
	@echo "  make artisan           Command for Laravel artisan. ex:) make artisan CM='migrate'"
	@echo "  make npm-install       npm install in the docker containers."
	@echo "  make npm-dev           Build npm files to pulic directory."
	@echo "  make npm-watch         Build assets files and watch modify."
	@echo
	@echo "  make setup             Setup for laravel project."
	@echo


.PHONY: open open-pma open-nginx

open:
	$(OPEN) http://$(IP):$(shell docker-compose -p $(APP_NAME) port apache 80 | cut -d':' -f2)

open-pma:
	$(OPEN) http://$(IP):$(shell docker-compose -p $(APP_NAME) port phpmyadmin 80 | cut -d':' -f2)

open-nginx:
	$(OPEN) http://$(IP):$(shell docker-compose -p $(APP_NAME) port nginx 80 | cut -d':' -f2)

.PHONY: build serve start stop down status restart serve-pma start-pma serve-nginx start-nginx

build:
	@docker-compose -p $(APP_NAME) build apache mysql smtp

serve:
	@docker-compose -p $(APP_NAME) up apache mysql smtp

start:
	@docker-compose -p $(APP_NAME) up -d apache mysql smtp

stop:
	@docker-compose -p $(APP_NAME) stop apache mysql smtp

restart: stop start

down:
	@docker-compose -p $(APP_NAME) down

status:
	@docker-compose -p $(APP_NAME) ps

serve-pma:
	@docker-compose -p $(APP_NAME) up --build phpmyadmin

start-pma:
	@docker-compose -p $(APP_NAME) up -d --build phpmyadmin

serve-nginx:
	@docker-compose -p $(APP_NAME) up --build nginx fpm

start-nginx:
	@docker-compose -p $(APP_NAME) up -d nginx fpm

.PHONY: shell composer-install migrate rollback seed routes composer composer-autoload artisan artisan-key-generate artisan-storage-link

shell:
	@docker-compose -p $(APP_NAME) exec apache /bin/bash

migrate:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan migrate

rollback:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan migrate:rollback

seed:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan db:seed

routes:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan route:list

composer-install:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm composer install

composer:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm composer ${CM}

composer-autoload:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm composer dump-autoload

artisan:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan ${CM}

artisan-key-generate:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan key:generate

artisan-storage-link:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm --entrypoint php composer artisan storage:link

.PHONY: npm npm-install npm-dev npm-watch

npm:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm npm ${CM}

npm-install:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm npm install

npm-dev:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm npm run dev

npm-watch:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm npm run watch

.PHONY: copy-env setup

copy-env:
	sh ./copy_env.sh

setup: copy-env build start composer-install npm-install artisan-key-generate artisan-storage-link migrate seed open

.PHONY: phpcs docker-phpcs

phpcs:
	php ./vendor/bin/phpcs -p -s --colors --report-full --report-summary --standard=./phpcs.xml ./app

docker-phpcs:
	@docker-compose -f docker-middleware.yml -p $(APP_NAME) run --rm composer php ./vendor/bin/phpcs -p -s --colors --report-full --report-summary --standard=./phpcs.xml ./app
