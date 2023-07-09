variable "external_id" {
  type        = string
  description = "This is your Grafana Cloud identifier and is used for security purposes."
  validation {
    condition     = length(var.external_id) > 0
    error_message = "ExternalID is required."
  }
  default = "1234"
}

variable "iam_role_name" {
  type        = string
  description = "Customize the name of the IAM role used by Grafana for the CloudWatch integration."
  default     = "GrafanaLabsCloudWatchIntegration"
}