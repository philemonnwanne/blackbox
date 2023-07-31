output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.tripvibe_distribution.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.tripvibe_distribution.id
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.tripvibe_distribution.hosted_zone_id
}

# ===============-========================
# CLOUDFRONT BUCKET
output "cloudfront_s3_arn" {
  value       = aws_s3_bucket.cloudfront.arn
  description = "the arn of the S3 bucket"
}

output "cloudfront_s3_id" {
  value       = aws_s3_bucket.cloudfront.id
  description = "the id of the S3 bucket"
}

output "cloudfront_s3_bucket_name" {
  value       = aws_s3_bucket.cloudfront.bucket
  description = "the id of the S3 bucket"
}

output "cloudfront_s3_domain_name" {
  value       = aws_s3_bucket.cloudfront.bucket_regional_domain_name
  description = "the id of the S3 bucket"
}
# CLOUDFRONT BUCKET
# ===============-========================

# output "tripvibe_s3_policy" {
#   value = data.aws_iam_policy_document.tripvibe_s3_policy.json
# }