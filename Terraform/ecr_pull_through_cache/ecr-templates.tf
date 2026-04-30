module "ecr_repository_template_dockerhub" {
  source = "terraform-aws-modules/ecr/aws//modules/repository-template"

  prefix      = "docker-hub"
  description = "Template for Docker Hub pull-through cache repositories"

  applied_for = ["PULL_THROUGH_CACHE"]

  image_tag_mutability = "MUTABLE"

  encryption_type = "AES256"

  # The module automatically adds a PrivateReadOnly statement for these ARNs.
  # No need to manually define repository_policy_statements for basic pull access.
  repository_read_access_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images per repository"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = var.tags
}

module "ecr_repository_template_ecr_public" {
  source = "terraform-aws-modules/ecr/aws//modules/repository-template"

  prefix      = "ecr-public"
  description = "Template for Public ECR pull-through cache repositories"

  applied_for = ["PULL_THROUGH_CACHE"]

  image_tag_mutability = "MUTABLE"

  encryption_type = "AES256"

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images per repository"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = var.tags
}
