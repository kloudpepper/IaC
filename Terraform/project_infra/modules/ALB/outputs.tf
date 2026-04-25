output "web_target_group_arn" {
  description = ""
  value       = aws_lb_target_group.target_group[0].arn
}

output "app_target_group_arn" {
  description = ""
  value       = aws_lb_target_group.target_group[1].arn
}

output "alb_name" {
  description = ""
  value       = aws_lb.alb.dns_name
}

output "alb_hosted_zone_id" {
  description = ""
  value       = aws_lb.alb.zone_id
}