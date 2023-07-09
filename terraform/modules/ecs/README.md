# Gaining Access to ECS Fargate Container

## Login to ECR

> Always do this before pushing to ECR

```bash
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
```

### Build the base nodejs image

Create ECR repo for the nodejs image

```sh
aws ecr create-repository \
  --repository-name vacation-vibe-nodejs \
  --image-tag-mutability MUTABLE
```

Set URL

```sh
export ECR_NODEJS_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/vacation-vibe-nodejs"

echo $ECR_NODEJS_URL
```

#### Pull Image

```sh
docker pull node:16.20.0-alpine3.18@sha256:f711d8a40d3515d7d44e344306382179fc8bfc4fe75f1a77b27a686a88649430
```

#### Tag Image

```sh
docker tag node:16.20.0-alpine3.18@sha256:f711d8a40d3515d7d44e344306382179fc8bfc4fe75f1a77b27a686a88649430 $ECR_NODEJS_URL:3.11.3-alpine
```

#### Push Image

```sh
docker push $ECR_NODEJS_URL:3.11.3-alpine
```

### Build the backend image

`Note:` In your flask dockerfile update the `FROM` command, so instead of using DockerHub's nodejs image
you use your own eg.

> remember to put the :latest tag on the end

Create ECR Repo for the backend

```sh
aws ecr create-repository \
  --repository-name backend \
  --image-tag-mutability MUTABLE
```

Set URL

```sh
export ECR_BACKEND_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/backend"
echo $ECR_BACKEND_URL
```

Build Image

```sh
docker build -t backend .
```

Tag Image

```sh
docker tag backend:latest $ECR_BACKEND_URL
```

Push Image

```sh
docker push $ECR_BACKEND_URL
```

## Register Task Defintions for the backend

### Passing Senstive Data to Task Defintion

Make sure the following are set as environment variables before running the following commands

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- CONNECTION_URL
- MONGO_URL
- $JWT_TOKEN

[specifying-sensitive-data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)

[secrets-envvar-ssm-paramstore](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-ssm-paramstore.html)

```sh
aws ssm put-parameter --type "SecureString" --name "/vacation-vibe/backend/AWS_ACCESS_KEY_ID" --value $AWS_ACCESS_KEY_ID
aws ssm put-parameter --type "SecureString" --name "/vacation-vibe/backend/AWS_SECRET_ACCESS_KEY" --value $AWS_SECRET_ACCESS_KEY
aws ssm put-parameter --type "SecureString" --name "/vacation-vibe/backend/CONNECTION_URL" --value $CONNECTION_URL
aws ssm put-parameter --type "SecureString" --name "/vacation-vibe/backend/MONGO_URL" --value $MONGO_URL
aws ssm put-parameter --type "SecureString" --name "/vacation-vibe/backend/MONGO_URL" --value $JWT_TOKEN
```

### Create Task and Exection Roles for Task Defintion

#### Create ExecutionRole

In the aws directory create a json file `/policies/service-execution-role.json` and add the following content

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      }
    }
  ]
}
```

Create the `vacation-vibeTaskExecutionRole`

```sh
aws iam create-role --role-name vacation-vibeTaskExecutionRole --assume-role-policy-document file://aws/policies/service-execution-role.json
```

Now create another json file `/policies/service-execution-policy.json` and add the following content

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter", 
        "ssm:GetParameters"
    ],
      "Resource": "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/*"
    }
  ]
}
```

Attach the `vacation-taskExecutionPolicy` policy

```sh
aws iam put-role-policy --policy-name vacation-taskExecutionPolicy --role-name vacation-vibeTaskExecutionRole --policy-document file://aws/policies/service-execution-policy.json
```

#### Create TaskRole

Create the `vacation-vibeTaskRole`

```sh
aws iam create-role \
    --role-name vacation-vibeTaskRole \
    --assume-role-policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[\"sts:AssumeRole\"],
    \"Effect\":\"Allow\",
    \"Principal\":{
      \"Service\":[\"ecs-tasks.amazonaws.com\"]
    }
  }]
}"
```

Attach the `SSMAccessPolicy` policy

```sh
aws iam put-role-policy \
  --policy-name SSMAccessPolicy \
  --role-name vacation-vibeTaskRole \
  --policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[
      \"ssmmessages:CreateControlChannel\",
      \"ssmmessages:CreateDataChannel\",
      \"ssmmessages:OpenControlChannel\",
      \"ssmmessages:OpenDataChannel\"
    ],
    \"Effect\":\"Allow\",
    \"Resource\":\"*\"
  }]
}
"
```

Attach the following policies for access to `CloudWatch` and `X-Ray`

`CloudWatchFullAccess` policy

```sh
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess --role-name vacation-vibeTaskRole
```

### Create a Task Definition for the `Backend`

Create a new folder called `aws/task-definitions` and place the following file in there:

`backend.json`

```json
{
  "family": "backend",
  "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/vacation-vibeTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/vacation-vibeTaskRole",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "BACKEND_IMAGE_URL",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "name": "backend",
          "containerPort": 4567,
          "protocol": "tcp", 
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "vacation-vibe",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "backend"
        }
      },
      "environment": [
        {"name": "OTEL_SERVICE_NAME", "value": "backend"},
        {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "https://api.honeycomb.io"},
        {"name": "AWS_COGNITO_USER_POOL_ID", "value": ""},
        {"name": "AWS_COGNITO_USER_POOL_CLIENT_ID", "value": ""},
        {"name": "FRONTEND_URL", "value": ""},
        {"name": "BACKEND_URL", "value": ""},
        {"name": "AWS_DEFAULT_REGION", "value": ""}
      ],
      "secrets": [
        {"name": "AWS_ACCESS_KEY_ID"    , "valueFrom": "arn:aws:ssm:AWS_REGION:AWS_ACCOUNT_ID:parameter/vacation-vibe/backend/AWS_ACCESS_KEY_ID"},
        {"name": "AWS_SECRET_ACCESS_KEY", "valueFrom": "arn:aws:ssm:AWS_REGION:AWS_ACCOUNT_ID:parameter/vacation-vibe/backend/AWS_SECRET_ACCESS_KEY"},
        {"name": "CONNECTION_URL"       , "valueFrom": "arn:aws:ssm:AWS_REGION:AWS_ACCOUNT_ID:parameter/vacation-vibe/backend/CONNECTION_URL" },
        {"name": "ROLLBAR_ACCESS_TOKEN" , "valueFrom": "arn:aws:ssm:AWS_REGION:AWS_ACCOUNT_ID:parameter/vacation-vibe/backend/ROLLBAR_ACCESS_TOKEN" },
        {"name": "OTEL_EXPORTER_OTLP_HEADERS" , "valueFrom": "arn:aws:ssm:AWS_REGION:AWS_ACCOUNT_ID:parameter/vacation-vibe/backend/OTEL_EXPORTER_OTLP_HEADERS" }
        
      ]
    }
  ]
}
```

### Register Task Defintion

Register the task definition for the backend

```sh
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/backend.json
```
