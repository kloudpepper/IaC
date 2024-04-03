variable "aws_Region" {
  type = string
}

variable "environment_Name" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "ecs_sg_id" {
  type = string
}

variable "docker_image" {
  type = string
}


variable "web_target_group_arn" {
  type = string
}

variable "app_target_group_arn" {
  type = string
}

variable "mq_endpoint" {
  type = string
}

variable "mq_password_arn" {
  type = string
}

variable "db_url" {
  type = string
}