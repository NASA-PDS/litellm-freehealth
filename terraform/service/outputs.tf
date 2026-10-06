output "alb_dns_name" {
  description = "DNS name of the LiteLLM Application Load Balancer"
  value       = aws_lb.litellm.dns_name
}

output "alb_arn" {
  description = "ARN of the LiteLLM ALB"
  value       = aws_lb.litellm.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.litellm.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.litellm.name
}
