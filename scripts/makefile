# make sure to have exported the included `env vars` before running make target
backend:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
	export ECR_BACKEND_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/backend"
	echo ${ECR_BACKEND_URL}
	docker build -t backend .
	docker tag backend:latest ${ECR_BACKEND_URL}
	docker push ${ECR_BACKEND_URL}