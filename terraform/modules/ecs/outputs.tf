output "cluster_network_config" {
    description = "network configuration for the service"
    value = aws_ecs_service.backend.network_configuration
}

output "cluster_task_id" {
  description = "id of the backend container"
  value = aws_ecs_service.backend.id
}

output "cluster_task_definition" {
  description = "task definition for the cluster"
  value = aws_ecs_service.backend.task_definition
}

output "cluster_name" {
  description = "name of the cluster"
  value = aws_ecs_cluster.tripvibe.name
}

output "cluster_launch_type" {
  description = "cluster type [fargate/ec2]"
  value = aws_ecs_service.backend.launch_type
}