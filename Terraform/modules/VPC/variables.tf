variable "aws_Region" {
  type    = string
  default = "us-east-1"
}

variable "environment_Type" {
  type    = string
  default = "dev"
}

variable "environment_Name" {
  type    = string
  default = "kloudpepper"
}

variable "vpc_CIDR" {
  type    = string
  default = "172.16.0.0/20"
  validation {
    condition     = tonumber(split("/", var.vpc_CIDR)[1]) <= 28 && tonumber(split("/", var.vpc_CIDR)[1]) >= 16
    error_message = "The CIDR block size must be between /16 and /28"
  }
}

variable "availability_Zones" {
  type    = number
  default = 2
  validation {
    condition     = var.availability_Zones <= 3 && var.availability_Zones >= 1
    error_message = "The number of availability zones must be between 1 and 3"
  }
}

variable "public_Subnets" {
  type    = number
  default = 2
  validation {
    condition     = var.public_Subnets <= 3 && var.public_Subnets >= 0
    error_message = "The number of public subnets must equal the number of availability zones"
  }
}

variable "private_Subnets" {
  type    = number
  default = 2
  validation {
    condition     = var.private_Subnets <= 6 && var.private_Subnets >= 0
    error_message = "The number of private subnets must be equal to or twice (*2) the number of availability zones"
  }
}

variable "create_NatGateway_1AZ" {
  type        = bool
  description = "Flag to create a NAT Gateway in one availability zone. The default is false. If true, it will create a NAT Gateway in one availability zone (AZ1)"
  default     = false
}

variable "create_NatGateway_1perAZ" {
  type        = bool
  description = "Flag to create a NAT Gateway in each availability zone. The default is false. If true, it will create a NAT Gateway in each availability zone"
  default     = false
}

variable "create_TransitGateway" {
  type        = bool
  description = "Flag to create a Transit Gateway. The default is false. If true, it will create a Transit Gateway and attach it to the VPC"
  default     = false
}

variable "route_TransitGateway" {
  type        = string
  description = "Add route to Transit Gateway. It should be to connect to another VPC or VPN (on-premises)"
  default     = "10.50.0.0/16"
}