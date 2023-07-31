# ===============-========================
# BACKEND BUCKET
# create an S3 bucket for our backend uploads
resource "aws_s3_bucket" "backend" {
  bucket        = "tripvibe-${local.tags["Environment"]}-${var.bucket_name}"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "backend" {
  bucket = aws_s3_bucket.backend.id
  rule {
    object_ownership = var.object_ownership
  }
}
# BACKEND BUCKET
# ===============-========================

locals {
  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "dev"
  }
}
