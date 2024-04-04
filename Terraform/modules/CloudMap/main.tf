resource "aws_service_discovery_http_namespace" "http_namespace" {
  name = "${var.environment_Name}.local"
}

resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  name        = "${var.environment_Name}.local"
  description = "${var.environment_Name}.local"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "web_discovery_service" {
  name = "web"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "app_discovery_service" {
  name = "app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
