variable "zone_id" {
  description = "ID of DNS zone"
  default = "Z05533031DW7NWR1EH80D"
}

variable "cloudfront_alias_name" {
  description = "domain name corresponding to the distribution"
}

variable "cloudfront_alias_zone_id" {
  description = "cloudfront Route 53 zone ID that can be used to route an Alias Resource Record Set to"
}

variable "alb_alias_name" {
  description = "the DNS name of the load balancer"
}

variable "alb_alias_zone_id" {
  description = "the canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)"
}