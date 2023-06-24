/* 
this block creates security groups for use with the instances
*/

module "backend_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = var.backend_security_group_name
  description = "security group controlling traffic to backend container downstream the application load balancer"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = var.backend_security_group_ingress_cidr
  ingress_rules       = var.backend_security_group_ingress_rules
  egress_cidr_blocks  = var.security_group_egress_cidr
  egress_rules        = var.security_group_egress_rules
  egress_ipv6_cidr_blocks = []
}

module "alb_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "4.17.1"
  name        = var.alb_security_group_name
  description = "security group controlling traffic to application load balancer upstream the backend container"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = var.alb_security_group_ingress_cidr
  ingress_rules       = var.alb_security_group_ingress_rules
  egress_cidr_blocks  = var.security_group_egress_cidr
  egress_rules        = var.security_group_egress_rules
  egress_ipv6_cidr_blocks = []
}