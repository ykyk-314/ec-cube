APP=ec-cube
USER=www-data

help:
	@grep "^[0-9a-zA-Z\.\-]*:" Makefile | grep -v "grep" | sed -e 's/^/make /' | sed -e 's/://'

php-v:
	docker compose exec -it -u ${USER} ${APP} php -v
composer-v:
	docker compose exec -it -u ${USER} ${APP} composer -V

up:
	docker compose up -d
build:
	docker compose build --no-cache --force-rm
stop:
	docker compose stop
down:
	docker compose down --remove-orphans
restart:
	@make down
	@make up
install:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:install
init:
	docker compose up -d --build
	@make install
remake:
	@make destroy
	@make init
destroy:
	docker compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker compose down --volumes --remove-orphans

ps:
	docker compose ps
logs:
	docker compose logs
logs-watch:
	docker compose logs --follow
log-${APP}:
	docker compose logs ${APP}
log-${APP}-watch:
	docker compose logs --follow ${APP}
log-app:
	docker compose logs app
log-app-watch:
	docker compose logs --follow app
log-db:
	docker compose logs db
log-db-watch:
	docker compose logs --follow db

bash:
	docker compose exec -it -u ${USER} ${APP} bash

migrate:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:migrations:migrate
migrate-generate:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:migrations:generate
migrate-status:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:migrations:status
# ex... version=Version20230116061053|20230116061053
migrate-up:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:migrations:execute ${version} --up | sed 's/Version//'
migrate-down:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:migrations:execute ${version} --down | sed 's/Version//'

clear:
	docker compose exec -it -u ${USER} ${APP} bin/console cache:clear --no-warmup
clear-warmup:
	docker compose exec -it -u ${USER} ${APP} bin/console cache:clear
proxies:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:generate:proxies
schema-update:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:schema:update --dump-sql
schema-update-force:
	docker compose exec -it -u ${USER} ${APP} bin/console doctrine:schema:update --dump-sql -f
composer-cache:
	docker compose exec -it -u ${USER} ${APP} composer dump-autoload

clear-all:
	rm -rf app/proxy/entiry/src
	@make composer-cache
	@make proxies
	@make clear
entity-update:
	@make proxies
	@make clear
	@make schema-update-force

# 
# ex... code=Api42
# 
# Copy and enter the plugin code from the plugin list.
# The first letter of the code must be capitalized.
# 
plg-install:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:plugin:install --code=${code}
plg-uninstall:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:plugin:uninstall --code=${code}
plg-enable:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:plugin:enable --code=${code}
plg-disable:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:plugin:disable --code=${code}
plg-package:
	docker compose exec -it -u ${USER} ${APP} bin/console eccube:composer:require ec-cube/${code} | sed 's/.\+/\L\0/'
plg-on:
	@make plg-package
	@make composer-cache
	@make clear
	@make plg-install
	@make plg-enable
plg-off:
	@make plg-uninstall
	@make plg-disable
	@make clear

db:
	docker compose exec mysql bash
db-exec:
	docker compose exec mysql bash -c 'mysql -u dbuser -psecret eccubedb'

