output "alb_dns" {
  description = "the DNS name of the load balancer."
  value       = aws_alb.alb.dns_name
}

output "alb_zone_id" {
  description = "the canonical hosted zone ID of the load balancer"
  value       = aws_alb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group."
  value       = aws_lb_target_group.alb_tg.arn
}

# output "alb_dns" {
#   description = "The DNS name of the load balancer."
#   value = "http://${aws_alb.alb.dns_name}"
# }
