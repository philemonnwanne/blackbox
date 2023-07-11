variable "alb_name" {
  description = "application load balancer name"
  type        = string
  default     = "backend-alb"
}

variable "vpc_id" {
  description = "VPC default id"
  type        = string
}

variable "subnets" {
  description = "a list of subnets to associate to the load balancer"
  type        = list(string)
}

variable "domain" {
  description = "domain name"
  type        = string
  default = "philemonnwanne.me"
}


variable "security_groups" {
  description = "the security groups to attach to the load balancer"
  type        = list(string)
}

variable "group_name" {
  description = "name prefix to assign to backend containers"
  type        = string
  default     = "backend-tg"
}

variable "target_type" {
  description = "load balancer target type e.g (instance)(ip-address)(lambda)"
  type        = string
  default     = "ip"
}
