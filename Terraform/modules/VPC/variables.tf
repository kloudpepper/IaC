variable "environmentName" {
	type    = string
}

variable "vpc_CIDR" {
	type    = string
}


variable "availability_Zones" {
	type 		= number
	validation {
		condition = var.availability_Zones <= 3 && var.availability_Zones >= 1
		error_message = "The number of availability zones must be between 1 and 3"
		}
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
