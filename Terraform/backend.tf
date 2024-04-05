terraform {
  backend "s3" {
    bucket = "kloudpepper-dev-state"
    key    = "terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "kloudpepper-dev-state"
    encrypt        = true
  }
}