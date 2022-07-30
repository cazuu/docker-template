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


.PHONY: open open-pma

open:
	$(OPEN) http://$(IP):$(shell docker-compose -p $(APP_NAME) port apache 80 | cut -d':' -f2)

open-pma:
	$(OPEN) http://$(IP):$(shell docker-compose -p $(APP_NAME) port phpmyadmin 80 | cut -d':' -f2)

.PHONY: build serve start stop down status restart serve-pma start-pma

build:
	@docker-compose -p $(APP_NAME) build

serve:
	@docker-compose -p $(APP_NAME) up

start:
	@docker-compose -p $(APP_NAME) up -d

stop:
	@docker-compose -p $(APP_NAME) stop

restart: stop start

down:
	@docker-compose -p $(APP_NAME) down

status:
	@docker-compose -p $(APP_NAME) ps

serve-pma:
	@docker-compose -p $(APP_NAME) up --build phpmyadmin

start-pma:
	@docker-compose -p $(APP_NAME) up -d --build phpmyadmin

.PHONY: shell composer-install migrate rollback seed routes composer composer-autoload artisan artisan-key-generate artisan-storage-link

shell:
	@docker-compose -p $(APP_NAME) exec apache /bin/bash

migrate:
	@docker-compose -p $(APP_NAME) exec apache php artisan migrate

rollback:
	@docker-compose -p $(APP_NAME) exec apache php artisan migrate:rollback

seed:
	@docker-compose -p $(APP_NAME) exec apache php artisan db:seed

routes:
	@docker-compose -p $(APP_NAME) exec apache php artisan route:list

composer-install:
	@docker-compose -p $(APP_NAME) exec apache composer install

composer:
	@docker-compose -p $(APP_NAME) exec apache composer ${CM}

composer-autoload:
	@docker-compose -p $(APP_NAME) exec apache composer dump-autoload

artisan:
	@docker-compose -p $(APP_NAME) exec apache php artisan ${CM}

artisan-key-generate:
	@docker-compose -p $(APP_NAME) exec apache php artisan key:generate

artisan-storage-link:
	@docker-compose -p $(APP_NAME) exec apache php artisan storage:link

.PHONY: npm npm-install npm-dev npm-watch

npm:
	@docker-compose -p $(APP_NAME) exec apache npm ${CM}

npm-install:
	@docker-compose -p $(APP_NAME) exec apache npm install

npm-dev:
	@docker-compose -p $(APP_NAME) exec apache npm run dev

npm-watch:
	@docker-compose -p $(APP_NAME) exec apache npm run watch

.PHONY: copy-env setup

copy-env:
	sh ./copy_env.sh

setup: copy-env build start composer-install npm-install artisan-key-generate artisan-storage-link migrate seed open

.PHONY: phpcs docker-phpcs

phpcs:
	php ./vendor/bin/phpcs -p -s --colors --report-full --report-summary --standard=./phpcs.xml ./app

docker-phpcs:
	@docker-compose -p $(APP_NAME) exec apache php ./vendor/bin/phpcs -p -s --colors --report-full --report-summary --standard=./phpcs.xml ./app

.PHONY: ide-helper-generate ide-helper-model ide-helper-meta ide-helper

ide-helper-generate:
	@docker-compose -p $(APP_NAME) exec apache php artisan ide-helper:generate

ide-helper-model:
	@docker-compose -p $(APP_NAME) exec apache php artisan ide-helper:model --nowrite

ide-helper-meta:
	@docker-compose -p $(APP_NAME) exec apache php artisan ide-helper:meta

ide-helper: ide-helper-generate ide-helper-model ide-helper-meta
