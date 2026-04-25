output "db_endpoint" {
  description = "The connection endpoint for the DB"
  value       = aws_db_instance.postgres_db.endpoint
}

output "db_url" {
  description = "The ARN of the DB URL parameter in SSM"
  value       = aws_ssm_parameter.db_url.arn
}