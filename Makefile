# Makefile for local development

.PHONY: down clean nuke

ifdef TAG
export TAG := $(TAG)
else
export TAG := dev
endif


# Builds core locally and sets to correct tag. This should take priority over DockerHub images
build-core:
	@docker-compose build


# Builds core locally and then runs pgrest in daemon mode
local-deploy: build-core
	@docker-compose run api python manage.py makemigrations
	@docker-compose run api python manage.py migrate
	@docker-compose up -d api


# Running the pgrest/test.py file
test:
	@docker-compose run api python manage.py test -v 2


# Pulls all Docker images not yet available but needed to run pgrest
pull:
	@docker-compose pull


# Ends all active Docker containers needed for pgrest
down:
	@docker-compose down

# Ends all active Docker containers needed for pgrest and clears all volumes
# If this is not used the postgres container will restart with data
down-volumes:
	@docker-compose down
	@docker volume prune -f


# Does a clean and also deletes all images needed for abaco
clean:
	@docker-compose down --remove-orphans -v --rmi all 


# Deletes ALL images, containers, and volumes forcefully
nuke:
	@docker rm -f `docker ps -aq`
	@docker rmi -f `docker images -aq`
	@docker container prune -f
	@docker volume prune -f

add-tenants:
	@curl -H "content-type: application/json" -d '{"schema_name": "admin", "db_instance": "local"}' -H "tapis-v2-token: $tok" localhost:5000/v3/pgrest/manage/tenants; echo
	@curl -H "content-type: application/json" -d '{"schema_name": "dev", "db_instance": "local"}' -H "tapis-v2-token: $tok" localhost:5000/v3/pgrest/manage/tenants; echo
	@curl -H "content-type: application/json" -d '{"schema_name": "tacc", "db_instance": "local"}' -H "tapis-v2-token: $tok" localhost:5000/v3/pgrest/manage/tenants; echo
	@curl -H "content-type: application/json" -d '{"schema_name": "cii", "db_instance": "local"}' -H "tapis-v2-token: $tok" localhost:5000/v3/pgrest/manage/tenants; echo
	@curl -H "content-type: application/json" -d '{"schema_name": "a2cps", "db_instance": "local"}' -H "tapis-v2-token: $tok" localhost:5000/v3/pgrest/manage/tenants; echo
