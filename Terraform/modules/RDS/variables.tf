variable "environment_Name" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "rds_sg_id" {
  type = string
}

variable "snapshot_ARN" {
  type = string
}