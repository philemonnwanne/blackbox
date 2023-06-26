module "vpc" {
  source = "../../modules/vpc"
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source = "../../modules/ecs"

  source_security_group_id = module.security.alb_security_group_id
  # subnet_ids = module.vpc.vpc_private_subnet_id
  subnet_ids = module.vpc.vpc_public_subnet_id
  # tags = local.tags
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

# module "cloudfront" {
#   source = "../../modules/cloudfront"
# }

# module "state" {
#   source = "../../global/statefile"
# }
