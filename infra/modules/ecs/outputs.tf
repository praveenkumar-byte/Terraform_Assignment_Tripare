output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "ecs_security_group_id" {
  description = "Passed to the rds module so RDS's SG can allow ingress only from this."
  value       = aws_security_group.ecs.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.this.name
}
