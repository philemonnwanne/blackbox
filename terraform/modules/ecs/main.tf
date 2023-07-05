resource "aws_ecs_cluster" "vacation-vibe" {
  name = "${var.cluster_name}"
  setting {
    name = "containerInsights"
    value = var.cluster_settings["value"]
  }
}

resource "aws_ecs_task_definition" "backend" {
  tags   = local.tags
  family             = "${var.task_name}"
  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn
  container_definitions = <<DEFINITION
  [
    {
        "name": "${var.task_name}",
        "image": "${var.ecr_image_uri}.ecr.${var.aws_region}.amazonaws.com/${var.task_name}",
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
          "containerPort": ${var.container_port},
          "protocol": "${local.protocol}",
          "appProtocol": "${local.app_protocol}"
        }
        ],
        "logConfiguration": {
        "logDriver": "${var.log_driver}",
        "options": {
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "${var.log_group}",
          "awslogs-stream-prefix": "ecs"
        }
        },
        "environment": [
        { "name": "S3_BUCKET_NAME", "value": "${var.cluster_name}" },
        { "name": "FRONTEND_URL", "value": "*" },
        { "name": "BACKEND_URL", "value": "*" },
        { "name": "AWS_REGION", "value": "${var.aws_region}" }
        ],
        "secrets": [
        {
            "name": "AWS_ACCESS_KEY_ID",
            "valueFrom": "${var.secret_manager_arn}/AWS_ACCESS_KEY_ID"
        },
        {
            "name": "AWS_SECRET_ACCESS_KEY",
            "valueFrom": "${var.secret_manager_arn}/AWS_SECRET_ACCESS_KEY"
        },
        
        {
            "name": "JWT_TOKEN",
            "valueFrom": "${var.secret_manager_arn}/JWT_TOKEN"
        },
        {
            "name": "MONGO_URL",
            "valueFrom": "${var.secret_manager_arn}/MONGO_URL"
        }
        ]
    }
  ]
  DEFINITION
  # These are the minimum values for Fargate containers.
  cpu                      = "${var.system_req.0}"
  memory                   = "${var.system_req[1]}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "${var.log_group}"
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

resource "aws_iam_role" "task_execution_role" {
  name               = "Vacation-vibeTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
# resource "aws_iam_role" "task_role" {
#   name               = "Vacation-VibeTaskRole"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }
# ------------------------- Step 1
# create policy document
data "aws_iam_policy_document" "task_execution_policy" {
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
# link policy document to `aws_iam_policy` resource
resource "aws_iam_policy" "task_execution_policy" {
   name        = "vacation-vibe-task-execution-policy"
   description = ""
   policy      = data.aws_iam_policy_document.task_execution_policy.json
}

# ----------------------- Step 3
# attaches the `aws_iam_policy` resource policy to the role in sstep 0
resource "aws_iam_role_policy_attachment" "task_execution_role_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}


# -------------------------

resource "aws_iam_role" "task_role" {
  name               = "Vacation-vibeTaskRole"
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
# link policy documentt to `aws_iam_policy` resource
resource "aws_iam_policy" "task_policy" {
   name        = "vacation-vibe-task-policy"
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
  tags   = local.tags
  name                 = "backend"
  task_definition      = aws_ecs_task_definition.backend.arn
  cluster              = "${aws_ecs_cluster.vacation-vibe.id}"
  launch_type          = "FARGATE"
  desired_count        = 1
  # depends_on      = [aws_iam_role_policy.foo] #To prevent a race condition during service deletion, we may not need tthis
  lifecycle {
    ignore_changes = [
        desired_count, 
        task_definition
      ]
    }
  enable_ecs_managed_tags = true
  # enable_execute_command = true only if we need to exec container and have ssm agent installed
  network_configuration {
    assign_public_ip = true
    security_groups = var.security_groups
    subnets = var.subnet_ids
  }
  # propagateTags   = "SERVICE"
  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.task_name}"
    container_port   = "${var.container_port}"
  }
  # service_connect_configuration {
  #   enabled = true
  #   namespace = var.cluster_name
  #   service {
  #     port_name = var.task_name
  #     discovery_name = var.task_name
  #     client_alias {
  #       port = var.container_port
  #     }
  #   }
  # }

  # register service discovery resource with ECS service
  # service_registries {
  #   registry_arn = "${aws_service_discovery_service.service_discovery_service.arn}"
  # }
}

# create a private service discovery DNS namespace for our ECS service
# resource "aws_service_discovery_private_dns_namespace" "service_discovery_namespace" {
#   name = "${var.domain_name}" # ecsdemo.cloud
#   vpc  = var.vpc_id
# }

# # associate private DNS namespace with aws_service_discovery_service resource
# resource "aws_service_discovery_service" "service_discovery_service" {
#   name = "${var.cluster_name}" #wp
#   dns_config {
#     namespace_id   = aws_service_discovery_private_dns_namespace.service_discovery_namespace.id
#     routing_policy = "MULTIVALUE"
#     dns_records {
#       ttl  = 10
#       type = "A"
#     }
#   }
#   health_check_custom_config {
#     failure_threshold = 5
#   }
# }

locals {
  protocol = "tcp"
  app_protocol = "http"

  tags = {
  Owner       = "Capstone-Group02"
  Track       = "Cloud/DevOps"
  Environment = "Prod"
}
}

# Will use this later, why? I don't remember, sha stay here mr/mrs resource
# resource "aws_service_discovery_private_dns_namespace" "ecs" {
#   name = var.private_dns_name # ecsdemo.cloud
#   vpc  = data.terraform_remote_state.vpc.outputs.vpc_id
# }