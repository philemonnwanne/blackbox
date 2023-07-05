provider "aws" {
  region = var.aws_region
}

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

# policy to allow the CloudFront `oia` to access the objects in the bucket
data "aws_iam_policy_document" "vacation_vibe_s3_policy" {
  statement {
    actions   = var.actions
    resources = ["${aws_s3_bucket.vacation_vibe_cloudfront.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "vacation_vibe_s3_bucket_policy" {
  bucket = aws_s3_bucket.vacation_vibe_cloudfront.id
  policy = data.aws_iam_policy_document.vacation_vibe_s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "vacation_vibe_s3_bucket_acl" {
  bucket                  = aws_s3_bucket.vacation_vibe_cloudfront.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# identity with which the S3 bucket is accessed
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront vacation-vibe origin-acess-identity"
}

resource "aws_cloudfront_distribution" "vacation_vibe_distribution" {
  tags   = local.tags
  # is_ipv6_enabled     = true
  enabled             = true
  comment             = "production distribution for vacation-vibe"
  default_root_object = "index.html"
  aliases = ["frontend.philemonnwanne.me"]

  origin {
    domain_name = var.domain_name
    origin_id   = var.alb_origin_id
    custom_origin_config {
      http_port              = local.http_port
      origin_protocol_policy = local.origin_protocol_policy
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      https_port             = local.https_port
    }
  }

  origin {
    # points CloudFront to the corresponding S3 bucket
    origin_id   = var.s3_origin_id
    domain_name = aws_s3_bucket.vacation_vibe_cloudfront.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    target_origin_id       = var.s3_origin_id
    viewer_protocol_policy = var.viewer_protocol_policy.0
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = var.path_pattern
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.alb_origin_id
    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "all"
      }
    }
    min_ttl                = local.min_ttl
    default_ttl            = local.default_ttl
    max_ttl                = local.max_ttl
    compress               = true
    viewer_protocol_policy = var.viewer_protocol_policy.1
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = "philemonnwanne.me"
  statuses = ["ISSUED"]
}

locals {
  mime_types             = jsondecode(file("${path.module}/mime.json"))
  s3_origin_id           = var.s3_origin_id
  environment            = var.environment
  http_port              = 80
  https_port             = 443
  min_ttl                = 0
  default_ttl            = 86400
  max_ttl                = 31536000
  origin_protocol_policy = "match-viewer"

  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "Prod"
  }
}
