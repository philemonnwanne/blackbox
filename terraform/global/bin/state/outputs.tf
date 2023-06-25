output "s3-bucket-name" {
    description = "name of the bucket"
    value = module.s3_bucket.s3_bucket_id
}

output "s3-bucket-arn" {
    description = "ARN of the bucket, format=arn:aws:s3:::bucketname"
    value = module.s3_bucket.s3_bucket_arn
}


# output "vacationvibe-state-arn" {
#   value       = aws_s3_bucket.vacationvibe-state.arn
#   description = "The ARN of the S3 bucket"
# }

# output "vacationvibe-state-id" {
#   value       = aws_s3_bucket.vacationvibe-state.id
#   description = "The ID of the S3 bucket"
# }

# output "vacationvibe-state-bucket" {
#   value       = aws_s3_bucket.vacationvibe-state.bucket
#   description = "The ID of the S3 bucket"
# }