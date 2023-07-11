# policy to allow the CloudFront `oia` to access the objects in the bucket
data "aws_iam_policy_document" "tripvibe_s3_policy" {
  statement {
    actions   = var.actions
    resources = var.resources
    # resources = ["${aws_s3_bucket.tripvibe_cloudfront.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

# identity with which the S3 bucket is accessed
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront tripvibe origin-acess-identity"
}

resource "aws_cloudfront_distribution" "tripvibe_distribution" {
  tags   = local.tags
  # is_ipv6_enabled     = true
  enabled             = true
  comment             = "production distribution for tripvibe"
  default_root_object = "index.html"
  aliases = ["frontend.philemonnwanne.me"]

  origin {
    # points CloudFront to the corresponding alb
    origin_id   = var.alb_origin_id
    domain_name = var.backend_domain_name
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
    domain_name = var.s3_domain_name

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
  domain   = var.domain
  statuses = ["ISSUED"]
}

locals {
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
