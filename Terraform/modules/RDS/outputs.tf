output "db_endpoint" {
  description = "The connection endpoint for the DB"
  value       = aws_db_instance.postgres_db.endpoint
}

output "db_password_arn" {
  description = "Secret ARN Password DB"
  value       = aws_secretsmanager_secret.db_password.arn
}