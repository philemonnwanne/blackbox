DOCKER_USERNAME ?= capgrp2
APPLICATION_NAME ?= vacvibe-frontend
GIT_HASH ?= $(shell git log --format="%h" -n 1)
 
build:
	docker build --tag ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} .
prod-build:
	docker build --tag ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} -f dockerfile.local .
push:
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
run:
	docker run --rm -p 5173:5173 ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
release:
	docker pull ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
	docker tag  ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest