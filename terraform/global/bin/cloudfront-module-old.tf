# provider "aws" {
#   region = local.region # CloudFront expects ACM resources in us-east-1 region only

#   # Make it faster by skipping something
#   skip_metadata_api_check     = true
#   skip_region_validation      = true
#   skip_credentials_validation = true

#   # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
#   skip_requesting_account_id = false
# }

# #############
# # S3 buckets
# #############
# data "aws_caller_identity" "current" {}

# data "aws_canonical_user_id" "current" {}

# resource "aws_iam_role" "this" {
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# data "aws_iam_policy_document" "vacation-vibe-s3-policy" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = [aws_iam_role.this.arn]
#     }

#     actions = [
#       "s3:ListBucket",
#     ]

#     resources = [
#       "arn:aws:s3:::${local.bucket_name}",
#     ]
#   }
# }

# # create an S3 bucket for our static web site artifacts
# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "vacation-vibe-${local.environment}-bucket"
#   acl    = "private"
#   # allow deletion of non-empty bucket
#   force_destroy = true
#   object_lock_enabled = true
#   # bucket policies
#   attach_policy                            = true
#   policy                                   = data.aws_iam_policy_document.vacation-vibe-s3-policy.json

#   versioning = {
#     enabled = true
#   }
# }

# #############
# # CloudFront
# #############

# module "cdn" {
#   source = "terraform-aws-modules/cloudfront/aws"

#   comment             = "production distribution for vacation-vibe"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   wait_for_deployment = false

#   create_origin_access_identity = true
#   origin_access_identities = {
#     s3_bucket_one = "My awesome CloudFront can access"
#   }

#   origin = {
#     something = {
#       domain_name = "something.example.com"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "match-viewer"
#         origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }

#     s3_one = {
#       domain_name = "my-s3-bycket.s3.amazonaws.com"
#       s3_origin_config = {
#         origin_access_identity = "s3_bucket_one"
#       }
#     }

#     s3_oac = { # with origin access control settings (recommended)
#       domain_name           = module.s3_one.s3_bucket_bucket_regional_domain_name
#       origin_access_control = "s3_bucket_oac" # key in `origin_access_control`
#       #      origin_access_control_id = "E345SXM82MIOSU" # external OAС resource
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id       = "something"
#     viewer_protocol_policy = "redirect-to-https"

#     allowed_methods = ["GET", "HEAD", "OPTIONS"]
#     cached_methods  = ["GET", "HEAD"]
#     compress        = true
#     query_string    = true
#   }

#   viewer_certificate = {
#     acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
#     ssl_support_method  = "sni-only"
#   }

#   tags = {
#     Owner = "${local.owner}"
#     Environment = "${local.environment}"
#   }
# }

# locals {
#   region       = "us-east-1"
#   mime_types   = jsondecode(file("${path.module}/mime.json"))
#   s3_origin_id = "vacation-vibe-origin"
#   environment  = "dev"
#   owner = "group2"
# }
