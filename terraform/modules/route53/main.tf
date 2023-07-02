# this block retrieves info about an existing hosted zone, which is in turn used to poupulate the records module
data "aws_route53_zone" "zone" {
  zone_id      = var.zone_id
  private_zone = false
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.zone.zone_id
  # zone_name = data.aws_route53_zone.zone.
  # records = var.records
  records = [
    {
      allow_overwrite = true
      name = "frontend"
      type = "A"
      alias = {
        name = var.cloudfront_alias_name
        zone_id = var.cloudfront_alias_zone_id
      }
    },
    {
      allow_overwrite = true
      name = "backend"
      type = "A"
      alias = {
        name = var.alb_alias_name
        zone_id = var.alb_alias_zone_id
      }
    }
  ]
}