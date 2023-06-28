/* 
this block creates security groups for use with the instances
*/

module "backend_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = var.backend_security_group_name
  description = "security group controlling traffic to backend container downstream the application load balancer"
  vpc_id              = var.vpc_id
  
  ingress_with_source_security_group_id = [
    {
      from_port   = local.backend_port
      to_port     = local.backend_port
      protocol    = "${local.tcp_protocol}"
      description = "access from the vacation-vibe ALB"
      cidr_blocks = local.all_ips
      source_security_group_id = module.alb_security_group.security_group_id
    }
  ]
  egress_cidr_blocks  = "${var.egress_cidr_blocks}"
  egress_rules        = var.egress_rules
  egress_ipv6_cidr_blocks = []
  tags = local.tags
}

module "alb_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = var.alb_security_group_name
  description = "security group controlling traffic to application load balancer upstream the backend container"
  vpc_id              = var.vpc_id
  ingress_with_cidr_blocks = var.alb_ingress_with_cidr_blocks
  ingress_cidr_blocks = "${var.ingress_cidr_blocks}"
  ingress_rules       = var.alb_ingress_rules
  egress_cidr_blocks  = "${var.egress_cidr_blocks}"
  egress_rules        = var.egress_rules
  egress_ipv6_cidr_blocks = []
  tags = local.tags
}

locals {
  backend_port   = 4000
  any_protocol   = "-1"
  tcp_protocol   = "tcp"
  all_ips        = "0.0.0.0/0"

  tags = {
    Owner = "Capstone-Group02"
    Track = "Cloud/DevOps"
  }
}