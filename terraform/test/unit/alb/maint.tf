module "alb" {
  source = "../../modules/alb"

  vpc_id = module.vpc.vpc_id
  # domain = module.route53.route53_zone_name
  subnets         = module.vpc.vpc_public_subnet_id
  security_groups = module.security.alb_security_group_id[*]
  # backend_target = module.ecs.backend_task_id
}