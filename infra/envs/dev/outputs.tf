output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "db_endpoint" {
  value = module.rds.endpoint
}

output "db_secret_arn" {
  value = module.rds.secret_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
