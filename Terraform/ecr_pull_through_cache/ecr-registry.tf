# This module manages the ECR registry settings, including pull through cache rules.
module "ecr_registry" {
  source = "terraform-aws-modules/ecr/aws"

  # We are managing registry-level settings, not creating a repository
  create_repository = false

  # Pull through cache rules
  registry_pull_through_cache_rules = {

    # Docker Hub — requires authentication via Secrets Manager
    dockerhub = {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
      credential_arn        = module.dockerhub_secret.secret_arn
    }

    # Public ECR — no authentication required
    ecr_public = {
      ecr_repository_prefix = "ecr-public"
      upstream_registry_url = "public.ecr.aws"
    }
  }

  tags = var.tags
}
