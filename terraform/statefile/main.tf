# this file defines the terraform block, which Terraform uses to configures itself

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
  required_version = ">= 1.1.0"
}

# this block configures the AWS provider
provider "aws" {
  region = local.region
}

# define common tags to be assigned to all VPC resources
locals {
  region = var.aws_region

  tags = {
    Owner = "Capstone Group02"
    Track = "Cloud/DevOps"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "vacation-vibe-state"
 
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# every update to a file in the bucket creates a new version of that file, a useful fallback mechanism if something goes wrong
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ensures that your state files, and any secrets they might contain, are always encrypted on disk when stored in S3
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block all public access to the S3 bucket + extra layer of protection to ensure no one on your team can ever accidentally make this S3 bucket public
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# connect to a DynamoDB table to use for locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "vacation-vibe-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}