module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = var.alb_name

  load_balancer_type = "application"

  vpc_id             = var.vpc_id
  subnets            = var.subnets
  security_groups    = var.security_groups

  target_groups = [
    {
      name_prefix      = var.target_groups_name
      backend_protocol = local.http_protocol
      backend_port     = 80
      target_type      = var.target_type
      targets = {
        target_01 = {
          target_id = var.target_01
          port = local.http_port
        }
        target_02 = {
          target_id = var.target_02
          port = local.http_port
        }
        target_03 = {
          target_id = var.target_03
          port = local.http_port
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = local.https_port
      protocol           = local.https_protocol
      certificate_arn    = var.ssl_cert
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = local.http_port
      protocol           = local.http_protocol
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Production"
  }
}

locals {
  http_port    = 80
  https_port   = 443
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "HTTP"
  https_protocol = "HTTPS"
  all_ips      = ["0.0.0.0/0"]
  tags = {
    Owner = "Capstone Group02"
    Track = "Cloud/DevOps"
  }
}