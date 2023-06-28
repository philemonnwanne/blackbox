variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "cluster_name" {
  description = "name of the cluster"
  type = string
  default = "vacation-vibe"
}

variable "task_name" {
  description = "the tasks name"
  default = "backend"
}

variable "ecr_image_uri" {
  description = "the ECR image url"
  type = string
  default = "183066416469.dkr"
}

variable "health_check_cmd" {
  description = "health check command to run on container start-up"
  type = string
  default = "npm --version || exit 1"
  # default = ["CMD-SHELL", "npm --version || exit 1"]
}

variable "cluster_settings" {
  description = "configuration block(s) with cluster settings"
  type = map(string)
  default = {
    name  = "containerInsights"
    value = "disabled"
  }

}

# variable "cluster_tags" {
#   description = "a map of additional tags to add to the cluster"
# }

variable "domain_name" {
  description = "custom domain name e.g.#mydomain.org"
  type = string
  default = "philemonnwanne.me"
}

variable "system_req" {
  description = "memory and cpu requirements"
  type = list(string)
  default = [
    256,
    512
  ]
}

variable "container_port" {
  description = "the port the container will listen on, used for load balancer health check Best practice is that this value is higher than 1024 so the container processes isn't running at root."
  type = number
  default = 4000
}

variable "security_groups" {
  description = "network configuration for the service"
}

variable "subnet_ids" {
  description = "vpc subnet ids"
  type        = list(string)
}

# variable "app" {
#   description = "ecs service name"
#   type        = string
# }

variable "environment" {
  description = "the environment that is being built"
  type = string
  default = ""
}

# variable "container_name" {
#   description = "the containers name"
#   type = any
# }

variable "target_group_arn" {
  description = "arn of the target group"
  type = string
}

variable "secret_manager_arn" {
  description = "the containers name"
  type = string
  default = "arn:aws:ssm:us-east-1:183066416469:parameter/vacation-vibe/backend"
}

variable "aws_region" {
  description = "region to deploy infrastructure"
  type = string
  default = "us-east-1"
}


variable "log_group" {
  description = "cloudwatch log-group for container logs"
  type = string
  default = "/ecs/backend"
}

variable "log_driver" {
  description = "aws log driver"
  type = string
  default = "awslogs"
}