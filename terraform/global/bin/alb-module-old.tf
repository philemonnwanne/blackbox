# Find a certificate that is issued
data "aws_acm_certificate" "cert_arn" {
  domain   = var.domain
  statuses = ["ISSUED","PENDING_VALIDATION","FAILED",]
}

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
      name_prefix      = var.target_group
      backend_protocol = local.http_protocol
      backend_port     = local.backend_port
      target_type      = var.target_type
      # targets = {
      #   backend_target = {
      #     target_id = var.backend_target
      #     port = local.backend_port
      #   }
        # target_02 = {
        #   target_id = var.target_02
        #   port = local.http_port
        # }
        # target_03 = {
        #   target_id = var.target_03
        #   port = local.http_port
        # }
      # }
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

  # https_listeners = [
  #   {
  #     port               = local.https_port
  #     protocol           = local.https_protocol
  #     certificate_arn    = "${data.aws_acm_certificate.cert_arn.arn}"
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = local.http_port
      protocol           = local.http_protocol
      forward = {
        target_groups = [
          {
            target_group_index = 0
            weight             = 100
          }
        ]
      }
    }
  ]

  tags = local.tags
}

# locals {
#   backend_port = 4000
#   http_port    = 80
#   https_port   = 443
#   any_protocol = "-1"
#   tcp_protocol = "tcp"
#   http_protocol = "HTTP"
#   https_protocol = "HTTPS"
#   all_ips      = ["0.0.0.0/0"]
#   tags = {
#     Owner = "Capstone-Group02"
#     Track = "Cloud/DevOps"
#   }
# }