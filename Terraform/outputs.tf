output "vpc_id" {
  value = module.VPC.vpc_id
}

output "public_subnet_ids" {
  value = module.VPC.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.VPC.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.VPC.internet_gateway_id
}

output "nat_gateway_ids" {
  value = module.VPC.nat_gateway_ids
}

output "transit_gateway_id" {
  value = module.VPC.transit_gateway_id
}

output "transit_gateway_attachment_id" {
  value = module.VPC.transit_gateway_attachment_id
}

output "public_route_table_id" {
  value = module.VPC.public_route_table_id
}

output "private_route_table_ids" {
  value = module.VPC.private_route_table_ids
}

output "public_nacl_id" {
  value = module.NACL.public_nacl_id
}

output "private_nacl_id" {
  value = module.NACL.private_nacl_id
}

output "alb_sg_id" {
  value = module.SG.alb_sg_id
}

output "eks_sg_id" {
  value = module.SG.eks_sg_id
}

output "mq_sg_id" {
  value = module.SG.mq_sg_id
}

output "rds_sg_id" {
  value = module.SG.rds_sg_id
}

output "vpc_endpoint_sg_id" {
  value = module.SG.vpc_endpoint_sg_id
}

output "db_endpoint" {
  value       = module.RDS.db_endpoint
}

output "db_password_arn" {
  value       = module.RDS.db_password_arn
}

output "mq_endpoint" {
  value       = module.MQ.mq_endpoint
}

output "mq_console" {
  value       = module.MQ.mq_console
}

output "mq_password_arn" {
  value       = module.MQ.mq_password_arn
}

output "web_target_group_arn" {
  value       = module.ALB.web_target_group_arn
}

output "app_target_group_arn" {
  value       = module.ALB.app_target_group_arn
}

output "alb_name" {
  value       = module.ALB.alb_name
}

output "alb_hosted_zone_id" {
  value       = module.ALB.alb_hosted_zone_id
}