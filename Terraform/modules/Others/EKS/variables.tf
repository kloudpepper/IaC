variable "environment_Name" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "eks_sg_id" {
  type = string
}