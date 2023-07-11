variable "object_ownership" {
  description = "objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "bucket_name" {
  description = "s3 bucket name"
  type        = string
  default     = "tripvibe"
}

variable "policy" {
  description = "s3 bucket name"
  type        = string
}
