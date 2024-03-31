output "mq_endpoint" {
  description = "Endpoint SSL ApacheMQ"
  value       = try(aws_mq_broker.apache_mq.instances[0].endpoints[0], "")
}

output "mq_console" {
  description = "Console URL ApacheMQ"
  value       = try(aws_mq_broker.apache_mq.instances[0].console_url, "")
}

output "mq_password_arn" {
  description = "Secret ARN Password ApacheMQ"
  value       = aws_secretsmanager_secret.mq_password.arn
}