DOCKER_USERNAME ?= capgrp2
AWS_DEFAULT_REGION = ${AWS_DEFAULT_REGION}
AWS_SECRET_ACCESS_KEY = ${AWS_SECRET_ACCESS_KEY}
AWS_ACCOUNT_ID = ${AWS_ACCOUNT_ID}
ECR_BACKEND_URL = ${ECR_BACKEND_URL}
 
backend:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
	export ECR_BACKEND_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/backend"
	echo ${ECR_BACKEND_URL}
	docker build -t backend .
	docker tag backend:latest ${ECR_BACKEND_URL}
	docker push ${ECR_BACKEND_URL}