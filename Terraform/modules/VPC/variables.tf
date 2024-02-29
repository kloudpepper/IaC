variable "environmentName" {
	type    = string
}

variable "vpc_CIDR" {
	type    = string
}

variable "private_subnet_1_CIDR" {
	type    = string
}

variable "private_subnet_2_CIDR" {
	type    = string
}

variable "reserved_subnet_CIDR" {
	type    = string
}

variable "transit_gateway_ID" {
	type    = string
}

variable "create_igw" {
  type        = bool
}

variable "create_transit_gateway_attachment" {
  type        = bool
}
