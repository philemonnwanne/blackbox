#alb.tf
resource "aws_lb_target_group" "alb_tg" {
  name        = "backend-tg"
  port        = local.backend_port
  protocol    = local.http_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    enabled = true
    path    = "/api"
  }
  # depends_on = [aws_alb.alb]
}

resource "aws_alb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups
  # depends_on = [aws_internet_gateway.igw]
  tags = local.tags
}

resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = local.backend_port
  protocol          = local.http_protocol
  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.alb_tg.arn
  # }
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = "philemonnwanne.me"
  statuses = ["ISSUED"]
}

locals {
  backend_port   = 4000
  http_port      = 80
  https_port     = 443
  any_protocol   = "-1"
  tcp_protocol   = "tcp"
  http_protocol  = "HTTP"
  https_protocol = "HTTPS"
  all_ips        = ["0.0.0.0/0"]
  tags = {
    Owner = "Capstone-Group02"
    Track = "Cloud/DevOps"
  }
}
