variable "atlas_org_id" {
  type        = string
  description = "Atlas Organization ID"
  default = "649a327d2277c80c223a0cd8"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "aws_region" {
  type        = string
  description = "aws region"
  default = "us-east-1"
}

variable "atlas_project_name" {
  type        = string
  description = "Atlas Project Name"
  default = "vacation-vibe"
}

variable "environment" {
  type        = string
  description = "The environment to be built [dev/stage/prod]"
  default = "dev"
}

variable "subnet_ids" {
  type        = list(string)
  description = "ID of the subnets"
}

variable "security_group_ids" {
  type        = set(string)
  description = "ID of the security group"
}

variable "cluster_instance_size_name" {
  type        = string
  description = "Cluster instance size name"
  default = "M0"
}

variable "cloud_provider" {
  type        = string
  description = "AWS or GCP or Azure"
  default = "AWS"
}

variable "atlas_region" {
  type        = string
  description = "Atlas region where resources will be created"
  default = "US_EAST_1"
}

variable "mongodb_version" {
  type        = string
  description = "MongoDB Version"
  default = "6.0"
}

# variable "ip_address" {
#   type = string
#   description = "IP address used to access Atlas cluster"
#   default = ""
# }

variable "cidr_block" {
  type = string
  description = "cidr block used to access Atlas cluster"
  default = "0.0.0.0/1"
}