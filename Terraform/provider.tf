terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_Region
  default_tags {
    tags = {
      EnvironmentType = var.environment_Type
      EnvironmentName = var.environment_Name
    }
  }
}

provider "random" {
}