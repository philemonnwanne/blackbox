module "alb" {
  source = "../../../modules/alb"

  vpc_id = module.vpc.vpc_id

  subnets         = module.vpc.vpc_public_subnet_id
  security_groups = module.security.alb_security_group_id[*]
  # backend_target = module.ecs.backend_task_id
}

output "alb_arn" {
  description = "The ARN name of the load balancer."
  value = module.alb.alb_arn
}

module "vpc" {
  source = "../../../modules/vpc"
}

module "security" {
  source = "../../../modules/security"

  vpc_id = module.vpc.vpc_id
}