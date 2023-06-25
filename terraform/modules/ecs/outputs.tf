# output "ecs_network_config" {
#     description = "network configuration for the service"
#     value = aws_ecs_service.backend.network_configuration
# }

# output "lb_zone_id" {
#   description = "the zone_id of the load balancer to assist with creating DNS records"
#   value = module.alb.lb_zone_id
# }