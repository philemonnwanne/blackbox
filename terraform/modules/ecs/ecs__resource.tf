resource "aws_ecs_cluster" "vacation-vibe" {
  name = "vacation-vibe"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family             = "backend"
  execution_role_arn = aws_iam_role.service_role.arn
  task_role_arn = aws_iam_role.task_role.arn
  container_definitions = <<EOF
  [
    {
        "name": "backend",
        "image": "183066416469.dkr.ecr.us-east-1.amazonaws.com/backend",
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

# ------------------------- Step 0
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = "Vacation-VibeServiceExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
# resource "aws_iam_role" "task_role" {
#   name               = "Vacation-VibeTaskRole"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }
# ------------------------- Step 1
# create policy document
data "aws_iam_policy_document" "service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
    }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/*"]
  }
}
# --------------------- Step 2
# link policy documnet to `aws_iam_policy` resource
resource "aws_iam_policy" "service_policy" {
   name        = "ecs-service-execution-policy"
   description = ""
   policy      = data.aws_iam_policy_document.service_policy.json
}

# ----------------------- Step 3
# attaches the `aws_iam_policy` resource policy to the role in sstep 0
resource "aws_iam_role_policy_attachment" "service_role_policy_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.service_policy.arn
}


# -------------------------

resource "aws_iam_role" "task_role" {
  name               = "Vacation-VibeTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
# ------------------------- Step 1
# create policy document
data "aws_iam_policy_document" "task_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}
# --------------------- Step 2
# link policy documnet to `aws_iam_policy` resource
resource "aws_iam_policy" "task_policy" {
   name        = "ecs-task-policy"
   description = ""
   policy      = data.aws_iam_policy_document.task_policy.json
}

# ----------------------- Step 3
# attach multiple policies with `for_each`
resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.task_role.name
  for_each = {
    "policy_one" = aws_iam_policy.task_policy.arn,
    # aws_iam_policy.other_policy.arn,

    # Works with AWS Provided policies too!
    "policy_two" = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  }

  policy_arn = each.value
}

# resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
#   role       = aws_iam_role.task_role.name
#   policy_arn = aws_iam_policy.task_policy.arn
# }

resource "aws_ecs_service" "backend" {
  name                 = "backend"
  task_definition = aws_ecs_task_definition.backend.arn
  cluster              = aws_ecs_cluster.vacation-vibe.id
  launch_type          = "FARGATE"
  lifecycle {
    ignore_changes = [
        desired_count, 
        task_definition
      ]
    }
  desired_count        = 1
  enable_ecs_managed_tags = true
  # enable_execute_command = true
  network_configuration {
    assign_public_ip = true
    security_groups = var.security_groups
    subnets = var.subnet_ids
  }
  # propagateTags   = "SERVICE"
  # load_balancer {
  #   # target_group_arn = module.vpc.vpc_id
  #   container_name   = "backend"
  #   container_port   = "4000"
  # }

}
