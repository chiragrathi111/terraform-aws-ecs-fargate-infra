output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "secret_arn" {
  description = "Secrets Manager ARN holding username/password/host/port/dbname"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
