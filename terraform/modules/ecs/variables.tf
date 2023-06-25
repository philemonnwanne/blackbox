variable "source_security_group_id" {
  description = "network configuration for the service"
}

variable "subnet_ids" {
  description = "vpc subnet ids"
  type        = list(string)
}

# variable "name" {
#   description = "ecs service name"
#   type        = string
# }

# variable "network_configuration" {
#   description = "network configuration for the service"
#   type = any
# }

# variable "load_balancer" {
#   description = "configuration block for load balancers"
#   type = any
# }
