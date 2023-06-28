#alb.tf
resource "aws_lb_target_group" "alb_tg" {
  name        = "backend-tg"
  port        = local.backend_port
  protocol    = local.http_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    enabled = true
    path    = "/api/"
    interval            = 10
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 6
  }
  depends_on = [aws_alb.alb]
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
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
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
