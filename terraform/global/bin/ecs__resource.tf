resource "aws_ecs_cluster" "vacation-vibe" {
  name = "vacation-vibe"
}

resource "aws_ecs_task_definition" "backend" {
  family             = "backend"
  execution_role_arn = aws_iam_role.backend_task_execution_role.arn
  #   container_definitions = jsondecode(file("../../global/aws/task-definitions/backend.json"))
  container_definitions = <<EOF
  [
    {
        "name": "backend",
        "image": "mohitmutha/simplefastifyservice:1.1",
        "essential": true,
        "healthCheck": {
        "command": ["CMD-SHELL", "npm --version || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
        },
        "portMappings": [
        {
            "containerPort": 4000,
            "protocol": "tcp",
            "appProtocol": "http"
        }
        ],
        "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-region": "us-east-1",
            "awslogs-group": "/ecs/backend",
            "awslogs-stream-prefix": "ecs"
        }
        },
        "environment": [
        { "name": "S3_BUCKET_NAME", "value": "vacation-vibe" },
        { "name": "FRONTEND_URL", "value": "*" },
        { "name": "BACKEND_URL", "value": "*" },
        { "name": "AWS_REGION", "value": "us-east-1" }
        ],
        "secrets": [
        {
            "name": "AWS_ACCESS_KEY_ID",
            "valueFrom": "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/AWS_ACCESS_KEY_ID"
        },
        {
            "name": "AWS_SECRET_ACCESS_KEY",
            "valueFrom": "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/AWS_SECRET_ACCESS_KEY"
        },
        {
            "name": "MONGO_URL",
            "valueFrom": "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/MONGO_URL"
        },
        {
            "name": "JWT_TOKEN",
            "valueFrom": "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/JWT_TOKEN"
        }
        ]
    }
  ]
  EOF
  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "/ecs/backend"
}

resource "aws_iam_role" "backend_task_execution_role" {
  name               = "backend-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is
# an AWS-managed policy, it's okay.
data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.backend_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "backend" {
  name                 = var.name
  cluster              = aws_ecs_cluster.vacation-vibe.id
  launch_type          = "FARGATE"
  desired_count        = 1
  enableECSManagedTags = true
  enableExecuteCommand = true
  network_configuration {
    assign_public_ip = false
    security_groups = [
    #   module.security.backend_security_group_id
    ]
    subnets = [
    #   module.vpc.vpc_private_subnet_id[0],
    #   module.vpc.vpc_private_subnet_id[1]
      #   aws_subnet.private_a.id
    ]
  }
  propagateTags   = "SERVICE"
  task_definition = aws_ecs_task_definition.backend.arn
  load_balancer {
    # target_group_arn = module.vpc.vpc_id
    container_name   = "backend"
    container_port   = "4000"
  }
  service_connect_configuration = {
    enabled  = true
    namspace = "vacation-vibe"
    service = [
      {
        port_name      = backend,
        discovery_name = backend,
        client_alias = [
          {
            port = 4000
          }
        ]
      }
    ]
  }
}
