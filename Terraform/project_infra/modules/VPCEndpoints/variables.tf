variable "aws_Region" {
  type = string
}

variable "environment_Name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "private_route_table_ids" {
  type    = list(string)
  default = []
}

variable "vpc_endpoint_sg_id" {
  type = string
}

variable "Services" {
  type = set(string)
}