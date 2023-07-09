output "atlas_cluster_connection_string" {
  description = "value"
  value       = mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.standard_srv
}

output "ip_access_list" {
  description = "grants access from IPs, CIDRs or AWS Security Groups (if VPC Peering is enabled) to clusters within the project"
  value       = mongodbatlas_project_ip_access_list.ip.ip_address
}

output "project_name" {
  description = "value"
  value       = mongodbatlas_project.atlas-project.name
}

output "username" {
  description = "database user which will be applied to all clusters within the project"
  value       = mongodbatlas_database_user.db-user.username
}

output "user_password" {
  description = "random password for the database user"
  sensitive   = true
  value       = mongodbatlas_database_user.db-user.password
}