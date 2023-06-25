provider "aws" {
  region = local.region
}

# create a cluster
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.2.0"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
  }
  tags = local.tags
}

# namespace mapping
resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

# create a service
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  # Container definition(s)
  container_definitions = {
    (local.name) = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
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
          Name                    = "backend"
          region                  = local.region
          delivery_stream         = "/ecs"
          log-driver-buffer-limit = "2097152"
        }
      }
      memory_reservation = 100
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

  subnet_ids = var.subnet_ids

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "service port"
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
