output "vacation_vibe_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.vacation_vibe_distribution.domain_name
}

output "vacation_vibe_cloudfront_id" {
  value = aws_cloudfront_distribution.vacation_vibe_distribution.id
}

output "vacation_vibe_cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.vacation_vibe_distribution.hosted_zone_id
}

output "vacation_vibe_s3_policy" {
  value = data.aws_iam_policy_document.vacation_vibe_s3_policy.json
}