locals {
  region = var.aws_region
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
  tags = {
    Owner = "Capstone Group02"
    Track = "Cloud/DevOps"
  }
}