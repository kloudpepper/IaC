############################
### VPC Endpoints Module ###
############################

locals {
  gateway_services = ["dynamodb", "s3"]

  InterfaceVPCEndpoint = toset([
    for service in var.Services :
    service if ! contains(local.gateway_services, service)
  ])

  GatewayVPCEndpoint = setintersection(var.Services, local.gateway_services)

  service_names_with_dns      = setunion(local.InterfaceVPCEndpoint)
  endpoint_resources_with_dns = merge(aws_vpc_endpoint.InterfaceVPCEndpoint)
}

# Create Interface VPC Endpoint
resource "aws_vpc_endpoint" "InterfaceVPCEndpoint" {
  for_each = local.InterfaceVPCEndpoint

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.VPCEnpointSecurityGroup_id]
  subnet_ids          = [var.PrivateSubnet1_id, var.PrivateSubnet2_id]
  private_dns_enabled = true

  tags = {
        Name          = "${var.environmentName}-endpoint-${each.value}"
    }
}

# Create Gateway VPC Endpoint
resource "aws_vpc_endpoint" "GatewayVPCEndpoint" {
  for_each = local.GatewayVPCEndpoint

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.PrivateRouteTable_id]

  tags = {
        Name          = "${var.environmentName}-endpoint-${each.value}"
    }
}