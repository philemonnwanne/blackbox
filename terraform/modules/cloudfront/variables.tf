variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "aws region"
  type        = string
  default = "backend.philemonnwanne.me"
}

variable "allowed_methods" {
  description = "controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  description = "controls whether CloudFront caches the response to requests using the specified HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "actions" {
  description = "allowed http methods"
  type        = list(string)
  default     = ["s3:GetObject"]
}

variable "path_pattern" {
  description = "specifies which requests you want this cache behavior to apply to"
  type        = string
  default     = "/api/*"
}

variable "viewer_protocol_policy" {
  description = "protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern"
  type        = list(string)
  default     = ["allow-all", "redirect-to-https"]
}

variable "s3_origin_id" {
  description = "unique identifier for the s3 bucket origin"
  type        = string
  default     = "vacation-vibe-s3-origin"
}

variable "alb_origin_id" {
  description = "unique identifier for the load balancer origin"
  type        = string
  default     = "vacation-vibe-alb-origin"
}

variable "environment" {
  description = "path pattern"
  type        = string
  default     = "dev"
}
