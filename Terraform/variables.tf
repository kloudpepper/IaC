variable "profile_AWS" {
  type = string
}

variable "environmentName" {
  type = string
}

variable "region" {
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

variable "ip_nat_IIB_onpremise" {
	type    = string
}

variable "certificate_ARN" {
	type    = string
}

variable "snapshot_ARN" {
	type    = string
}

variable "MQUser" {
	type    = string
}

variable "MQPassword" {
	type    = string
}

variable "ImageUrlWeb" {
	type 	= string
}

variable "ImageUrlDev" {
	type 	= string
}

variable "ImageUrlDevL3" {
	type 	= string
}

variable "ImageUrlTCUA" {
	type 	= string
}

variable "ImageUrlBFL" {
	type 	= string
}

variable "ImageUrlApp" {
	type 	= string
}

variable "ImageUrlBatch" {
	type 	= string
}

variable "DesiredCount" {
	type 	= number
}