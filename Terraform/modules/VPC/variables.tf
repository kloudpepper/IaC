variable "environment_Name" {
  type = string
}

variable "vpc_CIDR" {
  type = string
}

variable "availability_Zones" {
  type = number
}

variable "public_Subnets" {
  type    = number
  default = 2
}

variable "private_Subnets" {
  type    = number
  default = 2
}

variable "create_NatGateway_1AZ" {
  type = bool
}

variable "create_NatGateway_1perAZ" {
  type = bool
}

variable "create_TransitGateway" {
  type = bool
}

variable "route_TransitGateway" {
  type = string
}