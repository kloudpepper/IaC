terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.profile_AWS
  region                   = var.region
  default_tags {
   tags = {
     Environment = var.environmentName
     }
   }
}