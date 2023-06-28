variable "backend_security_group_name" {
  description = "backend security group name"
  type        = string
  default     = "backend-security-group"
}

variable "ingress_cidr_blocks" {
  description = "security group inbound CIDR block"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# variable "backend_ingress_rules" {
#   description = "allow traffic to the container"
#   type        = list(string)
#   default     = ["http-80-tcp"]
# }

# variable "backend_ingress_with_cidr_blocks" {
#   description = "access from the vacation-vibe ALB"
#   type        = list(map(string))
#   default = [
#     {
#       from_port   = 4000
#       to_port     = 4000
#       protocol    = "tcp"
#       description = "access from the vacation-vibe ALB"
#       cidr_blocks = "0.0.0.0/0"
#       source_security_group_id = module.alb_security_group.security_group_id
#     }
#   ]
# }

variable "vpc_id" {
  description = "VPC default id"
  type        = string
}

variable "egress_cidr_blocks" {
  description = "security group outbound CIDR block"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_rules" {
  description = "security group outbound rules"
  type        = list(string)
  default     = ["all-all"]
}

variable "alb_security_group_name" {
  description = "application load balancer security group name"
  type        = string
  default     = "alb-security-group"
}

variable "alb_ingress_rules" {
  description = "allow http/https traffic to the load balancer"
  type        = list(any)
  default = [
    "http-80-tcp",
    "https-443-tcp"
  ]
}

variable "alb_ingress_with_cidr_blocks" {
  description = "allow access to the backend-target-group"
  type        = list(map(string))
  default = [
    {
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "allow access to the backend-target-group"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
