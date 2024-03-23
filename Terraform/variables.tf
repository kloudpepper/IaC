variable "aws_Region" {
  type = string
}

variable "environment_Type" {
  type = string
}

variable "environment_Name" {
  type = string
}

variable "vpc_CIDR" {
  type = string
  validation {
    condition     = tonumber(split("/", var.vpc_CIDR)[1]) <= 28 && tonumber(split("/", var.vpc_CIDR)[1]) >= 16
    error_message = "The CIDR block size must be between /16 and /28"
  }
}

variable "availability_Zones" {
  type = number
  validation {
    condition     = var.availability_Zones <= 3 && var.availability_Zones >= 1
    error_message = "The number of availability zones must be between 1 and 3"
  }
}

variable "public_Subnets" {
  type = number
  validation {
    condition     = var.public_Subnets <= 3 && var.public_Subnets >= 0
    error_message = "The number of public subnets must equal the number of availability zones"
  }
}

variable "private_Subnets" {
  type = number
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
}

# variable "ImageUrlWeb" {
#   type = string
# }

# variable "ImageUrlApp" {
#   type = string
# }

# variable "DesiredCount" {
#   type = number
# }

# variable "regions" {
#   type = map(string)
#   default = {
#     us-east-1      = "use1"
#     us-east-2      = "use2"
#     us-west-1      = "usw1"
#     us-west-2      = "usw2"
#     af-south-1     = "afs1"
#     ap-south-1     = "aps1"
#     ap-south-2     = "aps2"
#     ap-east-1      = "ape1"
#     ap-southeast-1 = "apse1"
#     ap-southeast-2 = "apse2"
#     ap-southeast-3 = "apse3"
#     ap-southeast-4 = "apse4"
#     ap-northeast-1 = "apne1"
#     ap-northeast-2 = "apne2"
#     ap-northeast-3 = "apne3"
#     ca-central-1   = "cac1"
#     ca-west-1      = "caw1"
#     eu-central-1   = "euc1"
#     eu-west-1      = "euw1"
#     eu-west-2      = "euw2"
#     eu-west-3      = "euw3"
#     eu-south-1     = "eus1"
#     eu-south-2     = "eus2"
#     eu-north-1     = "eun1"
#     eu-central-2   = "euc2"
#     il-central-1   = "ilc1"
#     me-south-1     = "mes1"
#     me-central-1   = "mec1"
#     sa-east-1      = "sae1"
#   }
# }