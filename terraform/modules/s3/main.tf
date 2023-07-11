# create an S3 bucket for our backend uploads
resource "aws_s3_bucket" "backend" {
  bucket        = var.bucket_name
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

# ===============-========================
# CLOUDFRONT BUCKET

# create an S3 bucket for our static web site artifacts
resource "aws_s3_bucket" "vacation_vibe_cloudfront" {
  bucket = "vacation-vibe-${local.environment}-bucket"
  tags   = local.tags
}

# upload the content of the `build` folder as S3 objects
resource "aws_s3_object" "bucket_upload" {
  for_each     = fileset("../../../frontend/dist", "**/*.*")
  bucket       = aws_s3_bucket.vacation_vibe_cloudfront.id
  key          = each.key
  source       = "../../../frontend/dist/${each.value}"
  etag         = filemd5("../../../frontend/dist/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

resource "aws_s3_bucket_policy" "vacation_vibe_s3_bucket_policy" {
  bucket = aws_s3_bucket.vacation_vibe_cloudfront.id
  policy = var.policy
}
# CLOUDFRONT BUCKET
# ===============-========================

locals {

  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "Dev"
  }
}