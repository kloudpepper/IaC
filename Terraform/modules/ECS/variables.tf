variable "region" {
  type = string
}

variable "environmentName" {
  type = string
}

variable "PrivateSubnet1_id" {
  type = string
}

variable "PrivateSubnet2_id" {
  type = string
}

variable "ECSSecurityGroup_id" {
  type = string
}

variable "ImageUrlWeb" {
  type = string
}

variable "ImageUrlDev" {
  type = string
}

variable "ImageUrlDevL3" {
  type = string
}

variable "ImageUrlTCUA" {
  type = string
}

variable "ImageUrlBFL" {
  type = string
}

variable "ImageUrlApp" {
  type = string
}

variable "ImageUrlBatch" {
  type = string
}

variable "TargetGroupWEB_arn" {
  type = string
}

variable "TargetGroupDEV_arn" {
  type = string
}

variable "TargetGroupDEVL3_arn" {
  type = string
}

variable "TargetGroupTCUA_arn" {
  type = string
}

variable "TargetGroupAPP_arn" {
  type = string
}

variable "MQEnpointAddr" {
  type = string
}

variable "MQUser" {
  type = string
}

variable "MQPassword" {
  type = string
}

variable "EFSFileSystem_id" {
  type = string
}

variable "AccessPoint_import-request_id" {
  type = string
}

variable "AccessPoint_import-response_id" {
  type = string
}

variable "AccessPoint_import-error_id" {
  type = string
}

variable "AccessPoint_dw-export_id" {
  type = string
}

variable "AccessPoint_dfe_id" {
  type = string
}

variable "AccessPoint_udexternal_id" {
  type = string
}

variable "AccessPoint_cfrextract_id" {
  type = string
}

variable "AccessPoint_TAFJ_log_id" {
  type = string
}

variable "AccessPoint_TAFJ_logT24_id" {
  type = string
}

variable "DesiredCount" {
  type = number
}