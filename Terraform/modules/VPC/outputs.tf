output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "PrivateSubnet1_id" {
  description = "Private Subnet 1 ID"
  value       = aws_subnet.PrivateSubnet1.id
}

output "PrivateSubnet2_id" {
  description = "Private Subnet 2 ID"
  value       = aws_subnet.PrivateSubnet2.id
}

output "ReservedSubnet_id" {
  description = "Reserved Subnet ID"
  value       = aws_subnet.ReservedSubnet.id
}

output "PrivateRouteTable_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.PrivateRouteTable.id
}

output "ReservedRouteTable_id" {
  description = "Reserved Route Table ID"
  value       = aws_route_table.ReservedRouteTable.id
}