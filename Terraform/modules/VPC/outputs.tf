output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw[0].id
}

output "nat_gateway_ids" {
  value = var.create_NatGateway_1AZ ? aws_nat_gateway.nat_gateway_1AZ[*].id : var.create_NatGateway_1perAZ ? aws_nat_gateway.nat_gateway_1perAZ[*].id : []
}

output "transit_gateway_id" {
  value = var.create_TransitGateway ? aws_ec2_transit_gateway.transit_gateway[0].id : null
}

output "transit_gateway_attachment_id" {
  value = var.create_TransitGateway ? aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment[0].id : null
}

output "public_route_table_id" {
  value = var.public_Subnets != 0 ? aws_route_table.public_route_table[0].id : null
}

output "private_route_table_ids" {
  value = var.private_Subnets != 0 ? aws_route_table.private_route_tables[*].id : []
}