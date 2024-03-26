variable "aws_Region" {
  type = string
}

variable "environment_Name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "alb_sg_id" {
  type = string
}

variable "elb-account-id" {
  type = map(string)
  default = {
    us-east-1    = "127311923021"
    us-east-2    = "033677994240"
    us-west-1    = "027434742980"
    us-west-2    = "797873946194"
    eu-central-1 = "054676820928"
    eu-west-1    = "156460612806"
    eu-west-2    = "652711504416"
    eu-west-3    = "009996457667"
  }
}