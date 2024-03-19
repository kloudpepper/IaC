variable "environment_Name" {
  type = string
}

variable "vpc_CIDR" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}