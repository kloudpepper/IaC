output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "mq_sg_id" {
  value = aws_security_group.mq_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "vpc_endpoint_sg_id" {
  value = aws_security_group.vpc_endpoint_sg.id
}