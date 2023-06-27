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

variable "backend_ingress_rules" {
  description = "ecs backend service inbound rules"
  type        = list(string)
  default     = ["http-80-tcp"]
}

variable "backend_ingress_with_cidr_blocks" {
  description = "ecs backend service ports"
  type        = list(map(string))
  default = [
    {
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "CUSTOM"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

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
  description = "security group inbound rules"
  type        = list(any)
  default = [
    "http-80-tcp",
    "https-443-tcp"
  ]
}
