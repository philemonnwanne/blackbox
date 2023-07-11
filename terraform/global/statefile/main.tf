resource "aws_s3_bucket" "tripvibe_state" {
  bucket              = "tripvibe-state-${local.tags["Environment"]}"
  object_lock_enabled = true
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true
  tags          = local.tags
}

# every update to a file in the bucket creates a new version of that file, a useful fallback mechanism if something goes wrong
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.tripvibe_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ensures that your state files, and any secrets they might contain, are always encrypted on disk when stored in S3
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.tripvibe_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block all public access to the S3 bucket + extra layer of protection to ensure no one on the team can ever accidentally make this S3 bucket public
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.tripvibe_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# dynamodb table for locking the statefile
resource "aws_dynamodb_table" "state_locker" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

locals {
  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "dev"
  }
}
