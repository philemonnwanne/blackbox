variable "atlas_org_id" {
  type        = string
  description = "Atlas Organization ID"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "atlas_project_name" {
  type        = string
  description = "Atlas Project Name"
}

variable "environment" {
  type        = string
  description = "The environment to be built [dev/stage/prod]"
}

variable "subnet_ids" {
  type        = string
  description = "ID of the subnet"
}

variable "security_group_ids" {
  type        = string
  description = "ID of the security group"
}

variable "cluster_instance_size_name" {
  type        = string
  description = "Cluster instance size name"
}

variable "cloud_provider" {
  type        = string
  description = "AWS or GCP or Azure"
}

variable "atlas_region" {
  type        = string
  description = "Atlas region where resources will be created"
}

variable "mongodb_version" {
  type        = string
  description = "MongoDB Version"
}

variable "ip_address" {
  type = string
  description = "IP address used to access Atlas cluster"
}