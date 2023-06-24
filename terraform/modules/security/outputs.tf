output "backend_security_group_id" {
    description = "security group controlling traffic access to the backend instances"
    value = module.backend_security_group.security_group_id
}

output "alb_security_group_id" {
    description = "security group controlling traffic access to the application load balancer"
    value = module.alb_security_group.security_group_id
}