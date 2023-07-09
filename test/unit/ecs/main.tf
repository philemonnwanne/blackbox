module "ecs" {
  source = "../../modules/ecs"

  security_groups = module.security.backend_security_group_id[*]
  # subnet_ids = module.vpc.vpc_private_subnet_id
  subnet_ids = module.vpc.vpc_public_subnet_id
  # tags = local.tags
  vpc_id = module.vpc.vpc_id
  # target_group_arn = "${module.alb.target_group_arns[0]}"
  target_group_arn = module.alb.target_group_arn
}