provider "aws" {
  region = local.region
}

# create a cluster
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.2.0"

  cluster_name = "vacation-vibe"

#   # Capacity provider
#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#         base   = 20
#       }
#     }
#   }
  tags = local.tags
}

# namespace mapping
resource "aws_service_discovery_http_namespace" "this" {
  name        = "vacation-vibe"
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
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
resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.service_policy.arn
}

# create a service
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512
  enable_execute_command = true
  # execution_role_arn = "arn:aws:iam::183066416469:role/Vacation-VibeServiceExecutionRole"
  # task_role_arn = "arn:aws:iam::183066416469:role/CruddurTaskRole"

  # Container definition(s)
  container_definitions = {
    # task_role_arn = "arn:aws:iam::183066416469:role/CruddurTaskRole"
    # execution_role_arn = "arn:aws:iam::183066416469:role/CruddurServiceExecutionRole"
    (local.name) = {
      essential = true

      cluster_settings = {
        name = "containerInsights",
        value = "enabled"
      }
      image     = "183066416469.dkr.ecr.us-east-1.amazonaws.com/backend"
      health_check = {
        command = [
          "CMD-SHELL",
          "npm --version || exit 1"
        ],
        interval = 30,
        timeout = 5,
        retries = 3,
        start_period = 60
      }
      port_mappings = [
        {
          name          = local.name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      enable_cloudwatch_logging = false
      log_configuration = {
        logDriver = "awslogs"
        options = {
            awslogs-group = "ecs/vacation-vibe/backend"
            awslogs-region = local.region
            awslogs-stream-prefix = "backend"
        }
      }
      # memory_reservation = 100
      environment = [
        {
          name  = "S3_BUCKET_NAME", 
          value = "vacation-vibe"
        },
        {
          name  = "FRONTEND_URL",
          value = "*"
        },
        {
          name  = "BACKEND_URL",
          value = "*"
        },
        {
          name  = "AWS_REGION",
          value = "us-east-1"
        }
      ]
      secrets = [
        {
          name = "AWS_ACCESS_KEY_ID",
          valueFrom = "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/AWS_ACCESS_KEY_ID"
        },
        {
          name = "AWS_SECRET_ACCESS_KEY",
          valueFrom = "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/AWS_SECRET_ACCESS_KEY"
        },
        {
          name = "JWT_TOKEN",
          valueFrom = "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend/JWT_TOKEN" 
        }
      ]
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.name
      }
      port_name      = local.name
      discovery_name = local.name
    }
  }

#   load_balancer = {
#     service = {
#       target_group_arn = element(module.alb.target_group_arns, 0)
#       name   = local.name
#       container_port   = local.container_port
#     }
#   }

  assign_public_ip = true

  subnet_ids = var.subnet_ids

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "vacation-vibe backend service port"
      source_security_group_id = var.source_security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.everywhere
    }
  }

  tags = local.tags
}

locals {
  container_port = 4000
  name = "backend"
  region         = "us-east-1"
  everywhere       = ["0.0.0.0/0"]

  tags = {
    Owner       = "Capsrone-Group02"
    Environment = "Prod"
    Repository  = "https://github.com/capgpr2"
  }
}
