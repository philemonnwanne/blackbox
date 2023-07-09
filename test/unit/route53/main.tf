module "route53" {
  source = "../../modules/route53"
  cloudfront_alias_name = module.cloudfront.vacation_vibe_cloudfront_domain_name
  cloudfront_alias_zone_id = module.cloudfront.vacation_vibe_cloudfront_hosted_zone_id
  alb_alias_name = module.alb.alb_dns
  alb_alias_zone_id = module.alb.alb_zone_id
}