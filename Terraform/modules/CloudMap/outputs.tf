output "private_dns_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.private_dns_namespace.arn
}

output "web_discovery_service_arn" {
  value = aws_service_discovery_service.web_discovery_service.arn
}

output "app_discovery_service_arn" {
  value = aws_service_discovery_service.app_discovery_service.arn
}