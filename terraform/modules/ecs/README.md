<p align=right> 
<a href="https://gitpod.io/#https://github.com/philemonnwanne/aws-bootcamp-vacation-vibe-2023">
  <img
    src="https://img.shields.io/badge/Contribute%20with-Gitpod-908a85?logo=gitpod"
    alt="Contribute with Gitpod"
    style="text-align: right"
  />
</a>
</p>

# Deploying the backend container

## Implement health check for the backend container

```python
@app.route('/api/health-check')
def health_check():
  return {'success': True}, 200
```

Update `app.py`

```python

```

In the `backend/bin` directory, we will create a new directory `flask` and a script `health-check` with the following content.

```python
#!/usr/bin/env python3

import urllib.request

try:
  response = urllib.request.urlopen('http://localhost:4567/api/health-check')
  if response.getcode() == 200:
    print("[OK] Flask server is running")
    exit(0) # success
  else:
    print("[BAD] Flask server is not running")
    exit(1) # false
# This for some reason is not capturing the error....
#except ConnectionRefusedError as e:
# so we'll just catch on all even though this is a bad practice
except Exception as e:
  print(e)
  exit(1) # false
```

We will make it executable:

```bash
chmod 744 bin/flask/health-check
```

To execute the script:

```bash
./bin/flask/health-check
```

### Create Cloudwatch Logs

We would want to have a general log for our cluster, and also set the retention period to 1 day

```bash
aws logs create-log-group --log-group-name "vacation-vibe-fargate-cluster" \
aws logs put-retention-policy --log-group-name "vacation-vibe-fargate-cluster" --retention-in-days 1
```

### Create Fargate Cluster

```bash
aws ecs create-cluster \
--cluster-name vacation-vibe \
--service-connect-defaults namespace=vacation-vibe
```

### Gaining Access to ECS Fargate Container

### Login to ECR

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

### Build the frontend image

Create ECR Repo for the frontend

```sh
aws ecr create-repository \
  --repository-name frontend-react \
  --image-tag-mutability MUTABLE
```

Set URL

```sh
export ECR_FRONTEND_REACT_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/frontend-react"
echo $ECR_FRONTEND_REACT_URL
```

Build Image

```sh
docker build \
--build-arg REACT_APP_BACKEND_URL="https://4567-$GITPOD_WORKSPACE_ID.$GITPOD_WORKSPACE_CLUSTER_HOST" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="us-east-1_M2UeJ9auI" \
--build-arg REACT_APP_CLIENT_ID="5cj7ce7gvhr9fvevss7t6vfocs" \
-t frontend-react \
-f Dockerfile.prod \
.
```

Tag Image

```sh
docker tag frontend-react:latest $ECR_FRONTEND_REACT_URL:latest
```

Push Image

```sh
docker push $ECR_FRONTEND_REACT_URL:latest
```

If you want to run and test it

```sh
docker run --rm -p 3000:3000 -it frontend-react 
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

`AWSXRayDaemonWriteAccess` policy

```sh
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess --role-name vacation-vibeTaskRole
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

### Create Security Group

Export `VPC` id for the `VPC` name tag `vacation-vibe-vpc`

```sh
export vacation-vibe_VPC_ID=$(aws ec2 describe-vpcs \
--filters "Name=tag:Name, Values=vacation-vibe-vpc" \
--query "Vpcs[].VpcId" \
--output text)
echo $vacation-vibe_VPC_ID
```

<!-- Grab the `Subnet` ids

```sh
export vacation-vibe_SUBNET_ID=$(aws ec2 describe-subnets  \
--filters "Name=vpc-id, Values=$vacation-vibe_VPC_ID" \
--query 'Subnets[*].SubnetId' \
--output json | jq -r 'join(",")')
echo $vacation-vibe_SUBNET_ID
``` -->

Create security group

```sh
export CRUD_SERVICE_SG=$(aws ec2 create-security-group \
  --group-name "crud-srv-sg" \
  --description "Security group for vacation-vibe services on ECS" \
  --vpc-id $vacation-vibe_VPC_ID \
  --query "GroupId" --output text)
echo $CRUD_SERVICE_SG
```

Describe security group (if it already exists)

```sh
export CRUD_SERVICE_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name, Values=crud-srv-sg" \
  --query "SecurityGroups[*].{ID:GroupId}" \
  --output text)
echo $CRUD_SERVICE_SG
```

Add ingress rule

```sh
aws ec2 authorize-security-group-ingress \
  --group-id $CRUD_SERVICE_SG \
  --protocol tcp \
  --port 4567 \
  --cidr 0.0.0.0/0
```

### Extras
<!-- This has been done earlier 👆🏾  -->
<!-- Fix docker push error (denied: Your authorization token has expired. Reauthenticate and try again.)

```sh
aws ecr get-login-password \
    --region <region> \
| docker login \
    --username AWS \
    --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
``` -->

### Not able to use Sessions Manager to get into cluster EC2 sintance

The instance can hang up for various reasons. 
You need to reboot and it will force a restart after 5 minutes. 
So you will have to wait 5 minutes or after a timeout.

You have to use the AWS CLI. 
You can't use the `AWS Console`, it will not work as expected.

The console will only do a graceful shutdodwn. 
The CLI will do a forceful shutdown after a period of time if graceful shutdown fails.

```sh
aws ec2 reboot-instances --instance-ids i-0d15aef0618733b6d
```

### Connection via Sessions Manaager (Fargate)

`Note:` Add these commands to `gitpod.yml`

[Install the Session Manager plugin on Debian](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian)

Install for Ubuntu

```sh
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
```

Run the install command

```sh
sudo dpkg -i session-manager-plugin.deb
```

Verify that the installation was successful

```sh
session-manager-plugin
```

### Create Services

While in the `project` directory

```sh
aws ecs create-service --cli-input-json file://aws/services/service-backend.json
```

<!-- ```sh
aws ecs create-service --cli-input-json file://aws/services/service-frontend-react.json
``` -->

### Connect to the container

```sh
aws ecs execute-command  \
--region $AWS_DEFAULT_REGION \
--cluster vacation-vibe \
--task dceb2ebdc11c49caadd64e6521c6b0c7 \
--container backend \
--command "/bin/sh" \
--interactive
```

### Connect to the container (script)

In the backend directory, create a new script `bin/ecs/connect-to-ecs` so we can easily login to our ecs container.

```sh
# Script compatible with both zsh and bash shells
#!/usr/bin/env bash
set -e # stop if it fails at any point

if [ -z "$1" ]; then
  echo "No TASK_ID argument was supplied eg .bin/ecs/connect-to-ecs b0f2a4f926b545b9b99992b0eefc5860 backend"
  exit 1
fi
TASK_ID=$1

if [ -z "$2" ]; then
  echo "No CONTAINER_NAME argument was supplied eg .bin/ecs/connect-to-ecs b0f2a4f926b545b9b99992b0eefc5860 backend"
  exit 1
fi
CONTAINER_NAME=$2

aws ecs execute-command  \
--region $AWS_DEFAULT_REGION \
--cluster vacation-vibe \
--task $TASK_ID \
--container $CONTAINER_NAME \
--command "/bin/sh" \
--interactive
```

We will make it executable:

```bash
chmod 744 bin/ecs/connect-to-ecs
```

To execute the script:

```bash
./bin/ecs/connect-to-ecs
```

<!-- ```sh
docker run -rm \
-p 4567:4567 \
-e AWS_ENDPOINT_URL="http://dynamodb-local:8000" \
-e CONNECTION_URL="postgresql://postgres:password@db:5432/vacation-vibe" \
-e FRONTEND_URL="https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}" \
-e BACKEND_URL="https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}" \
-e OTEL_SERVICE_NAME='backend' \
-e OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io" \
-e OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=${HONEYCOMB_API_KEY}" \
-e AWS_XRAY_URL="*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*" \
-e AWS_XRAY_DAEMON_ADDRESS="xray-daemon:2000" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e ROLLBAR_ACCESS_TOKEN="${ROLLBAR_ACCESS_TOKEN}" \
-e AWS_COGNITO_USER_POOL_ID="${AWS_COGNITO_USER_POOL_ID}" \
-e AWS_COGNITO_USER_POOL_CLIENT_ID="5b6ro31g97urk767adrbrdj1g5" \   
-it backend-prod
``` -->

# Connecting via a load balancer

### Create Security Group

Export `VPC` id for the `VPC` name tag `vacation-vibe-vpc`

```sh
export vacation-vibe_VPC_ID=$(aws ec2 describe-vpcs \
--filters "Name=tag:Name, Values=vacation-vibe-vpc" \
--query "Vpcs[].VpcId" \
--output text)
echo $vacation-vibe_VPC_ID
```

Grab the `public subnet` ids

<!-- ```sh
export vacation-vibe_SUBNET_ID=$(aws ec2 describe-subnets  \
--filters "Name=vpc-id, Values=$vacation-vibe_VPC_ID" "Name=tag:Name, Values=vacation-vibe-subnet-public3-us-east-1c" \
--query 'Subnets[*].SubnetId' \
--output json | jq -r 'join(",")')
echo $vacation-vibe_SUBNET_ID
``` -->

```sh
export vacation-vibe_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id, Values=$vacation-vibe_VPC_ID" | jq -r '.Subnets[] | select(.Tags[].Value | contains("public")).SubnetId')
echo $vacation-vibe_SUBNET_ID
```

Create security group for the ALB

```sh
export CRUD_ALB_SG=$(aws ec2 create-security-group \
  --group-name "crud-alb-sg" \
  --description "Security group for vacation-vibe ALB on ECS" \
  --vpc-id $vacation-vibe_VPC_ID \
  --query "GroupId" --output text)
echo $CRUD_ALB_SG
```

Describe security group (if it already exists)

```sh
export CRUD_ALB_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name, Values=crud-alb-sg" \
  --query "SecurityGroups[*].{ID:GroupId}" \
  --output text)
echo $CRUD_ALB_SG
```

Update ingress rule for the `crud-alb-sg` 

```sh
aws ec2 authorize-security-group-ingress --group-id $CRUD_ALB_SG --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges="[{CidrIp=0.0.0.0/0,Description=allow http access}]" IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges="[{CidrIp=0.0.0.0/0,Description=allow secure access}]" IpProtocol=tcp,FromPort=4567,ToPort=4567,IpRanges="[{CidrIp=0.0.0.0/0,Description=allow access to the backend-target-group}]" IpProtocol=tcp,FromPort=3000,ToPort=3000,IpRanges="[{CidrIp=0.0.0.0/0,Description=allow access to the frontend-target-group}]"
```

Revoke previous ingress rule for the `crud-srv-sg`

```sh
aws ec2 revoke-security-group-ingress \
    --group-name $CRUD_SERVICE_SG
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

Update ingress rule for the `crud-srv-sg`

<!-- ```sh
aws ec2 authorize-security-group-ingress \
  --group-id $CRUD_SERVICE_SG \
  --description "access from crudder ALB" \
  --protocol tcp \
  --port 4567 \
  --source-group $CRUD_ALB_SG
``` -->

```sh
aws ec2 authorize-security-group-ingress --group-id $CRUD_SERVICE_SG --ip-permissions IpProtocol=tcp,FromPort=4567,ToPort=4567,UserIdGroupPairs="[{GroupId=$CRUD_ALB_SG, Description=access from crudder ALB}]"
```

### Create a Load Balancer

Create load balancer

```sh
export vacation-vibe_ALB_ARN=$(aws elbv2 create-load-balancer \
--name vacation-vibe-alb \
--scheme internet-facing \
--subnets $vacation-vibe_SUBNET_ID \
--security-groups $CRUD_ALB_SG \
--query "LoadBalancers[*].LoadBalancerArn" \
--output text)
echo $vacation-vibe_ALB_ARN
```

Describe load balancer (if it already exists)

```sh
export vacation-vibe_ALB_DNS=http://$(aws elbv2 describe-load-balancers \
--names vacation-vibe-alb \
--query "LoadBalancers[*].DNSName" \
--output text):4567
echo "~~~~~~~~~"
echo  OUTPUT 👾
echo "~~~~~~~~~"
echo $vacation-vibe_ALB_DNS
```

Create the `backend` target group

```sh
export vacation-vibe_BACKEND_TARGETS=$(
aws elbv2 create-target-group \
--name vacation-vibe-backend-tg \
--protocol HTTP \
--port 4567 \
--vpc-id $vacation-vibe_VPC_ID \
--ip-address-type ipv4 \
--target-type ip \
--health-check-protocol HTTP \
--health-check-path /api/health-check \
--healthy-threshold-count 3 \
--query "TargetGroups[*].TargetGroupArn" \
--output text)
echo $vacation-vibe_BACKEND_TARGETS
```

Create listener for the `backend` target group

```sh
aws elbv2 create-listener --load-balancer-arn $vacation-vibe_ALB_ARN \
--protocol HTTP --port 4567  \
--default-actions Type=forward,TargetGroupArn=$vacation-vibe_BACKEND_TARGETS \
--output text \
--color on
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

### Create the backend service

While in the `project` directory

```sh
aws ecs create-service --cli-input-json file://aws/services/service-backend.json
```

Regsiter Targets for the `backend` target group

```sh
aws elbv2 register-targets --target-group-arn $vacation-vibe_BACKEND_TARGETS  \
--targets Id=192.98.76.90 Id=10.0.6.1 \
--output text \
--color on
```

Create the `frontend-react` target group

```sh
export vacation-vibe_FRONTEND_REACT_TARGETS=$(
aws elbv2 create-target-group \
--name vacation-vibe-frontend-react-tg \
--protocol HTTP \
--port 3000 \
--vpc-id $vacation-vibe_VPC_ID \
--ip-address-type ipv4 \
--target-type ip \
--query "TargetGroups[*].TargetGroupArn" \
--output text)
echo $vacation-vibe_FRONTEND_REACT_TARGETS
```

Create listener for the `frontend-react` target group

```sh
aws elbv2 create-listener --load-balancer-arn $vacation-vibe_ALB_ARN \
--protocol HTTP --port 3000  \
--default-actions Type=forward,TargetGroupArn=$vacation-vibe_FRONTEND_REACT_TARGETS \
--output text \
--color on
```

Regsiter Targets for the `frontend-react` target group

```sh
aws elbv2 register-targets --target-group-arn $vacation-vibe_FRONTEND_REACT_TARGETS  \
--targets Id=192.98.76.90 Id=10.0.6.1 \
--output text \
--color on
```

### Build the frontend image

Create ECR Repo for the frontend

```sh
aws ecr create-repository \
  --repository-name frontend-react \
  --image-tag-mutability MUTABLE
```

Set URL

```sh
export ECR_FRONTEND_REACT_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/frontend-react"
echo $ECR_FRONTEND_REACT_URL
```

Build Image

```sh
docker build \
--build-arg REACT_APP_BACKEND_URL="http://$vacation-vibe_ALB_DNS:4567" \
--build-arg REACT_APP_AWS_PROJECT_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_COGNITO_REGION="$AWS_DEFAULT_REGION" \
--build-arg REACT_APP_AWS_USER_POOLS_ID="$AWS_COGNITO_USER_POOL_ID" \
--build-arg REACT_APP_CLIENT_ID="$AWS_COGNITO_USER_POOL_CLIENT_ID" \
-t frontend-react \
-f Dockerfile.prod \
.
```

Tag Image

```sh
docker tag frontend-react:latest $ECR_FRONTEND_REACT_URL
```

#### Login to ECR

> Always do this before pushing to ECR

```bash
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
```

Push Image

```sh
docker push $ECR_FRONTEND_REACT_URL
```

If you want to run and test it

```sh
docker run --rm -p 3000:3000 -it frontend-react 
```

### Create a Task Definition for the `Frontend`

Goto `aws/task-definitions` and place the following file in there:

`frontend-react.json`

```json
{
  "family": "frontend-react",
  "executionRoleArn": "arn:aws:iam::183066416469:role/vacation-vibeTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::183066416469:role/vacation-vibeTaskRole",
  "networkMode": "awsvpc",
  "cpu": "256",
  "memory": "512",
  "requiresCompatibilities": [ 
    "FARGATE" 
  ],
  "containerDefinitions": [
    {
      "name": "frontend-react",
      "image": "183066416469.dkr.ecr.us-east-1.amazonaws.com/frontend-react",
      "essential": true,
      "portMappings": [
        {
          "name": "frontend-react",
          "containerPort": 3000,
          "protocol": "tcp", 
          "appProtocol": "http"
        }
      ],

      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "vacation-vibe-fargate-cluster",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "frontend-react"
        }
      }
    }
  ]
}
```

### Register Task Defintion

While in the `project` directory run

```sh
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/frontend-react.json
```

### Create the frontend service

While in the `project` directory

```sh
aws ecs create-service --cli-input-json file://aws/services/service-frontend-react.json
```

## Ext[ras](#)

### Generate sample aws cli skeleton

```sh
aws ec2 describe-security-groups --generate-cli-skeleton
```

### Enable ALB access logs (Skip if you are concerned about spend/bills)

Enable ALB access logs via the `console`

[enable-access-logging](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html)

Enable ALB access logs via the `cli`

[modify-load-balancer-attributes](https://docs.aws.amazon.com/cli/latest/reference/elbv2/modify-load-balancer-attributes.html)