module "vpc" {
  source = "../../modules/vpc"
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.vpc.vpc_id
}

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

# terraform {
#   backend "s3" {
#     # Replace this with your bucket name!
#     bucket    = "vacationvibe-state-dev"
#     key       = "dev/terraform.tfstate"
#     region    = "us-east-1"
#     encrypt   = true
#   }
# }

module "cloudfront" {
  source = "../../modules/cloudfront"

  domain_name = module.alb.alb_dns
}

module "route53" {
  source = "../../modules/route53"

}

module "alb" {
  source = "../../modules/alb"

  vpc_id = module.vpc.vpc_id
  # domain = module.route53.route53_zone_name
  subnets         = module.vpc.vpc_public_subnet_id
  security_groups = module.security.alb_security_group_id[*]
  # backend_target = module.ecs.backend_task_id
}

# module "state" {
#   source = "../../global/statefile"
# }
