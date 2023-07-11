variable "region" {
  description = "region to deploy all aws project resources"
  type        = string
  default     = "us-east-1"
}

variable "key" {
  description = "path to the state file inside the S3 bucket"
  type        = string
  default     = "dev/terraform.tfstate"
}