provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_caller_identity" "current" {}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "vacationvibe-state-${local.environment}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}


# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.49.0"
#     }
#   }
#   required_version = ">= 1.1.0"
# }

# # this block configures the AWS provider
# provider "aws" {
#   region = local.region
# }

# resource "aws_s3_bucket" "vacationvibe-state" {
#   bucket = "vacationvibe-state-${local.environment}"
#   object_lock_enabled = true
#   # Prevent accidental deletion of this S3 bucket
#   lifecycle {
#     prevent_destroy = true
#   }
#   tags = local.tags
# }

# # every update to a file in the bucket creates a new version of that file, a useful fallback mechanism if something goes wrong
# resource "aws_s3_bucket_versioning" "enabled" {
#   bucket = aws_s3_bucket.vacationvibe-state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # ensures that your state files, and any secrets they might contain, are always encrypted on disk when stored in S3
# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = aws_s3_bucket.vacationvibe-state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # block all public access to the S3 bucket + extra layer of protection to ensure no one on your team can ever accidentally make this S3 bucket public
# resource "aws_s3_bucket_public_access_block" "public_access" {
#   bucket                  = aws_s3_bucket.vacationvibe-state.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

locals {
  region = "us-east-1"
  environment = "prod"

  tags = {
    Owner = "Capstone-Group02"
    Track = "Cloud/DevOps"
  }
}
