# Secret for Docker Hub credentials used by ECR Pull Through Cache
module "dockerhub_secret" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name        = "ecr-pullthroughcache/dockerhub"
  description = "Docker Hub credentials for ECR Pull Through Cache"

  # Set to 0 for immediate deletion in non-prod environments
  recovery_window_in_days = 0

  # ignore_secret_changes prevents Terraform from overwriting the secret
  # if it is rotated or updated externally (e.g. via CI/CD)
  ignore_secret_changes = true

  # Required keys: username and accessToken (not password)
  secret_string = jsonencode({
    username    = var.dockerhub_username
    accessToken = var.dockerhub_access_token
  })

  tags = var.tags
}
