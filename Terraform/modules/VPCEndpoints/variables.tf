variable "region" {
	type 	= string
}

variable "environmentName" {
	type 	= string
}

variable "vpc_id" {
	type 	= string
}

variable "PrivateSubnet1_id" {
	type 	= string
}

variable "PrivateSubnet2_id" {
	type 	= string
}

variable "PrivateRouteTable_id" {
	type 	= string
}

variable "VPCEnpointSecurityGroup_id" {
	type 	= string
}

variable "Services" {
  type      = set(string)
}