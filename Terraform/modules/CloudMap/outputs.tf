output "private_dns_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
}

output "web_discovery_service" {
  value = aws_service_discovery_service.web_discovery_service.arn
}

output "app_discovery_service" {
  value = aws_service_discovery_service.app_discovery_service.arn
}