output "db_endpoint" {
  description = "The connection endpoint for the DB"
  value       = aws_db_instance.postgres_db.endpoint
}

output "db_password_key_arn" {
  description = "The ARN of the KMS key for the DB password"
  value       = aws_kms_key.db_password.arn
}