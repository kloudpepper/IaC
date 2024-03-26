output "EFSFileSystem_id" {
  description = "Exportar FileSystemId"
  value       = aws_efs_file_system.EFSFileSystem.id
}

output "AccessPoint_import-request_id" {
  description = "Exportar AccessPointId import-request"
  value       = aws_efs_access_point.import-request.id
}

output "AccessPoint_import-response_id" {
  description = "Exportar AccessPointId import-response"
  value       = aws_efs_access_point.import-response.id
}

output "AccessPoint_import-error_id" {
  description = "Exportar AccessPointId import-error"
  value       = aws_efs_access_point.import-error.id
}

output "AccessPoint_dw-export_id" {
  description = "Exportar AccessPointId dw-export"
  value       = aws_efs_access_point.dw-export.id
}

output "AccessPoint_dfe_id" {
  description = "Exportar AccessPointId dfe"
  value       = aws_efs_access_point.dfe.id
}

output "AccessPoint_udexternal_id" {
  description = "Exportar AccessPointId udexternal"
  value       = aws_efs_access_point.udexternal.id
}

output "AccessPoint_cfrextract_id" {
  description = "Exportar AccessPointId cfrextract"
  value       = aws_efs_access_point.cfrextract.id
}

output "AccessPoint_TAFJ_log_id" {
  description = "Exportar AccessPointId TAFJ_log"
  value       = aws_efs_access_point.TAFJ_log.id
}

output "AccessPoint_TAFJ_logT24_id" {
  description = "Exportar AccessPointId TAFJ_logT24"
  value       = aws_efs_access_point.TAFJ_logT24.id
}