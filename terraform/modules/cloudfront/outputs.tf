output "vacation-vibe-cloudfront-arn" {
  value       = aws_s3_bucket.vacation-vibe-cloudfront.arn
  description = "the arn of the S3 bucket"
}

output "vacation-vibe-cloudfront-id" {
  value       = aws_s3_bucket.vacation-vibe-cloudfront.id
  description = "the id of the S3 bucket"
}

output "vacation-vibe-cloudfront-bucket" {
  value       = aws_s3_bucket.vacation-vibe-cloudfront.bucket
  description = "the id of the S3 bucket"
}

output "vacation_vibe_cloudfront_dns" {
  value = aws_cloudfront_distribution.vacation-vibe-distribution.domain_name
}

output "vacation_vibe_cloudfront_id" {
  value = aws_cloudfront_distribution.vacation-vibe-distribution.id
}