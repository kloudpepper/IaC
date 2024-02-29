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




### NEW
variable "AWS_region" {
  type    = string
}

variable "VPC_id" {
	type 	= string
}

variable "PrivateSubnet1_id" {
	type    = string
}

variable "PrivateSubnet2_id" {
	type    = string
}

variable "ALBSecurityGroup_id" {
	type    = string
}
variable "ALB_name" {
	type    = string
}

variable "ALB_port" {
	type    = string
}

variable "ALB_protocol" {
	type    = string
}

variable "CERTIFICATE_arn" {
	type    = string
}

variable "Stickiness" {
	type    = bool
}

variable "TG_port" {
	type    = string
}

variable "TG_protocol" {
	type    = string
}

variable "INSTANCES_id" {
	type    = list(string)
}

variable "Env" {
  type    = string
}

variable "AWS_regions" {
  type    = map(string)
  default = {
	us-east-1		= "use1"
	us-east-2		= "use2"
	us-west-1		= "usw1"
	us-west-2		= "usw2"
	af-south-1		= "afs1"
	ap-south-1		= "aps1"
	ap-south-2		= "aps2"
	ap-east-1		= "ape1"
	ap-southeast-1	= "apse1"
	ap-southeast-2	= "apse2"
	ap-southeast-3	= "apse3"
	ap-southeast-4	= "apse4"
	ap-northeast-1	= "apne1"
	ap-northeast-2	= "apne2"
	ap-northeast-3	= "apne3"
	ca-central-1	= "cac1"
	ca-west-1		= "caw1"
	eu-central-1	= "euc1"
	eu-west-1		= "euw1"
	eu-west-2		= "euw2"
	eu-west-3		= "euw3"
	eu-south-1		= "eus1"
	eu-south-2		= "eus2"
	eu-north-1		= "eun1"
	eu-central-2	= "euc2"
	il-central-1	= "ilc1"
	me-south-1		= "mes1"
	me-central-1	= "mec1"
	sa-east-1		= "sae1"
	}
}