module "security" {
  source = "../../modules/security"

  vpc_id = module.vpc.vpc_id
}