############################
### VPC Endpoints Module ###
############################

locals {
  gateway_services = ["dynamodb", "s3"]

  InterfaceVPCEndpoint = toset([
    for service in var.Services :
    service if !contains(local.gateway_services, service)
  ])

  GatewayVPCEndpoint = setintersection(var.Services, local.gateway_services)

  service_names_with_dns      = setunion(local.InterfaceVPCEndpoint)
  endpoint_resources_with_dns = merge(aws_vpc_endpoint.InterfaceVPCEndpoint)
}

# Create Interface VPC Endpoint
resource "aws_vpc_endpoint" "aws_vpc_endpoint_interface" {
  for_each = local.InterfaceVPCEndpoint

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_Region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.vpc_endpoint_sg_id]
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true

  tags = {
    Name = "${var.environment_Name}-endpoint-${each.value}"
  }
}

# Create Gateway VPC Endpoint
resource "aws_vpc_endpoint" "aws_vpc_endpoint_gateway" {
  for_each = local.GatewayVPCEndpoint

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_Region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "${var.environment_Name}-endpoint-${each.value}"
  }
}