output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "endpoint" {
  description = "Connection endpoint, host:port."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname only, no port."
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "secret_arn" {
  description = "Secrets Manager ARN holding username/password/host/port/dbname. ECS task definition reads this at container start."
  value       = aws_secretsmanager_secret.db_credentials.arn
}
