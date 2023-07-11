output "tripvibe_state_arn" {
  value       = aws_s3_bucket.tripvibe_state.arn
  description = "The ARN of the S3 bucket"
}

output "tripvibe_state_id" {
  value       = aws_s3_bucket.tripvibe_state.id
  description = "The ID of the S3 bucket"
}

output "tripvibe_state_bucket" {
  value       = aws_s3_bucket.tripvibe_state.bucket
  description = "The ID of the S3 bucket"
}