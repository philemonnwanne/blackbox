output "vacation_vibe_cloudfront_s3_arn" {
  value       = aws_s3_bucket.vacation_vibe_cloudfront.arn
  description = "the arn of the S3 bucket"
}

output "vacation_vibe_cloudfront_s3_id" {
  value       = aws_s3_bucket.vacation_vibe_cloudfront.id
  description = "the id of the S3 bucket"
}

output "vacation_vibe_cloudfront_s3_bucket_name" {
  value       = aws_s3_bucket.vacation_vibe_cloudfront.bucket
  description = "the id of the S3 bucket"
}

output "vacation_vibe_cloudfront_dns" {
  value = aws_cloudfront_distribution.vacation_vibe_distribution.domain_name
}

output "vacation_vibe_cloudfront_id" {
  value = aws_cloudfront_distribution.vacation_vibe_distribution.id
}