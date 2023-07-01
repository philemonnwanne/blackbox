DOCKER_USERNAME ?= capgrp2
APPLICATION_NAME ?= vacvibe-backend
GIT_HASH ?= $(shell git log --format="%h" -n 1)
 
build:
	docker build --tag ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} .
push:
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
run:
	docker run --rm -p 4000:4000 ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
release:
	docker pull ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
	docker tag  ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest
	
# make sure to have exported the included `env vars` before running make target
backend:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
	export ECR_BACKEND_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/backend"
	echo ${ECR_BACKEND_URL}
	docker build -t backend .
	docker tag backend:latest ${ECR_BACKEND_URL}
	docker push ${ECR_BACKEND_URL}