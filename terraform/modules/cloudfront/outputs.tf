output "tripvibe_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.tripvibe_distribution.domain_name
}

output "tripvibe_cloudfront_id" {
  value = aws_cloudfront_distribution.tripvibe_distribution.id
}

output "tripvibe_cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.tripvibe_distribution.hosted_zone_id
}

output "tripvibe_s3_policy" {
  value = data.aws_iam_policy_document.tripvibe_s3_policy.json
}