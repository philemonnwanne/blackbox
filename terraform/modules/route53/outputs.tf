output "zone_id" {
    description = "ID of DNS zone"
    value = data.aws_route53_zone.zone.id
}

output "zone_name" {
    description = "ID of DNS zone"
    value = data.aws_route53_zone.zone.name
}

# output "route53_zone_zone_arn" {
#   description = "Zone ARN of Route53 zone"
#   value       = data.aws_route53_zone.zone
# }

# output "route53_zone_name_servers" {
#   description = "Name servers of Route53 zone"
#   value       = module.zones.route53_zone_name_servers
# }

# output "route53_zone_name" {
#   description = "Name of Route53 zone"
#   value       = module.records.
# }