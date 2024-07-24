variable "account_number" {
  type = string
}

variable "project" {
  type = string
}

variable "project_short" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
  default     = {}
}
