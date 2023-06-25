# module "vpc" {
#   source = "../../modules/cloudfront"

#   name            = var.vpc_name
#   cidr            = var.cidr

#   tags = local.tags
# }

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket    = "vacationvibe-state-dev"
    key       = "dev/terraform.tfstate"
    region    = "us-east-1"
    encrypt   = true
  }
}

module "cloudfront" {
  source = "../../modules/cloudfront"
}

module "state" {
  source = "../../global/statefile"
}
