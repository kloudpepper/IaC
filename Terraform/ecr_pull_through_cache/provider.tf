terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      {
        Environment = var.environment
        Terraform   = "true"
      },
      var.tags
    )
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
