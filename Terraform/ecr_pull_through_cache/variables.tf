variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.region))
    error_message = "Region must be a valid AWS region format (e.g. eu-west-1)."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, pre, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "pre", "prod"], var.environment)
    error_message = "Environment must be one of: dev, pre, prod."
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "dockerhub_username" {
  type      = string
  sensitive = true
}

variable "dockerhub_access_token" {
  type      = string
  sensitive = true
}
