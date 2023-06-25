output "vpc_id" {
    description = "project VPC ID"
    value = module.vpc.vpc_id
}

output "vpc_name" {
    description = "project VPC name"
    value = module.vpc.name
}

output "vpc_public_subnet_id" {
    description = "project VPC public subnets"
    value = module.vpc.public_subnets
}

output "vpc_private_subnet_id" {
    description = "project VPC private subnet"
    value = module.vpc.private_subnets
}

output "vpc_security_group_id" {
    description = "project VPC default security group ID"
    value = module.vpc.default_security_group_id
}

output "azs" {
    description = "a list of availability zones"
    value = module.vpc.azs
}