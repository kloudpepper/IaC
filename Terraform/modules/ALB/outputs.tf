output "TargetGroupWEB_arn" {
  description = "Exportar Target Group para el contenedor Web"
  value       = aws_lb_target_group.TargetGroups[0].arn
}

output "TargetGroupDEV_arn" {
  description = "Exportar Target Group para el contenedor Dev"
  value       = aws_lb_target_group.TargetGroups[1].arn
}

output "TargetGroupDEVL3_arn" {
  description = "Exportar Target Group para el contenedor DevL3"
  value       = aws_lb_target_group.TargetGroups[2].arn
}

output "TargetGroupTCUA_arn" {
  description = "Exportar Target Group para el contenedor TCUA"
  value       = aws_lb_target_group.TargetGroups[3].arn
}

output "TargetGroupAPP_arn" {
  description = "Exportar Target Group para el contenedor App"
  value       = aws_lb_target_group.TargetGroups[4].arn
}