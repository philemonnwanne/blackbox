provider "aws" {
  region = local.region
}

# create an S3 bucket for our static web site artifacts
resource "aws_s3_bucket" "vacation-vibe-cloudfront" {
  bucket = "vacation-vibe-${local.environment}-bucket"
  tags   = local.tags
}

# upload the content of the `build` folder as S3 objects
resource "aws_s3_object" "bucket-upload" {
  for_each     = fileset("../../../frontend/dist", "**/*.*")
  bucket       = aws_s3_bucket.vacation-vibe-cloudfront.id
  key          = each.key
  source       = "../../../frontend/dist/${each.value}"
  etag         = filemd5("../../../frontend/dist/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

# policy to allow the CloudFront `oia` to access the objects in the bucket
data "aws_iam_policy_document" "vacation-vibe-s3-policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.vacation-vibe-cloudfront.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "vacation-vibe-s3-bucket-policy" {
  bucket = aws_s3_bucket.vacation-vibe-cloudfront.id
  policy = data.aws_iam_policy_document.vacation-vibe-s3-policy.json
}

resource "aws_s3_bucket_public_access_block" "vacation-vibe_s3_bucket_acl" {
  bucket                  = aws_s3_bucket.vacation-vibe-cloudfront.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# identity with which the S3 bucket is accessed
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront vacation-vibe origin-acess-identity"
}

resource "aws_cloudfront_distribution" "vacation-vibe-distribution" {
  is_ipv6_enabled     = true
  enabled             = true
  comment             = "production distribution for vacation-vibe"
  default_root_object = "index.html"

  origin {
    domain_name = aws_alb.alb.dns_name
    origin_id   = local.api_origin_id
    custom_origin_config {
      http_port              = 80
      origin_protocol_policy = "http-only"
    }
  }

  origin {
    # points CloudFront to the corresponding S3 bucket
    origin_id   = local.s3_origin_id
    domain_name = aws_s3_bucket.vacation-vibe-cloudfront.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.api_origin_id
    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "all"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# output "vacation_vibe_cloudfront_dns" {
#   value = aws_cloudfront_distribution.vacation-vibe-distribution.domain_name
# }

# output "vacation_vibe_cloudfront_id" {
#   value = aws_cloudfront_distribution.vacation-vibe-distribution.id
# }

locals {
  api_origin_id = "vacation-vibe-alb"
  region        = "us-east-1"
  mime_types    = jsondecode(file("${path.module}/mime.json"))
  s3_origin_id  = "vacation-vibe-origin"
  environment   = "dev"

  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "Prod"
  }
}
