output "backend_s3_arn" {
  value       = aws_s3_bucket.backend.arn
  description = "the arn of the S3 bucket"
}

output "backend_s3_id" {
  value       = aws_s3_bucket.backend.id
  description = "the id of the S3 bucket"
}

output "backend_s3_bucket_name" {
  value       = aws_s3_bucket.backend.bucket
  description = "the id of the S3 bucket"
}