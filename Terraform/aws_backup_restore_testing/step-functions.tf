# Step Functions state machine for backup restore validation
locals {
  restore_validation_db_instance_class = "db.r6g.large"
  restore_validation_engine            = "aurora-postgresql"
  restore_validation_database          = "PETS"
  restore_validation_schema            = "testing"
  restore_validation_table             = "pets"
  restore_validation_secret_arn        = module.cluster.cluster_master_user_secret[0].secret_arn
}

module "backup_restore_validation_sfn" {
  source = "terraform-aws-modules/step-functions/aws"

  name = "sfn-backup-restore-validation"
  type = "STANDARD"

  definition = templatefile("${path.module}/backup_restore_validation_asl.json", {
    db_instance_class = local.restore_validation_db_instance_class
    engine            = local.restore_validation_engine
    database          = local.restore_validation_database
    schema            = local.restore_validation_schema
    table             = local.restore_validation_table
    secret_arn        = local.restore_validation_secret_arn
  })

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.backup_restore_validation_sfn.json

  logging_configuration = {
    include_execution_data = true
    level                  = "ALL"
  }

  cloudwatch_log_group_name              = "/aws/vendedlogs/states/sfn-backup-restore-validation"
  cloudwatch_log_group_retention_in_days = 14

  tags = var.tags
}

# Policy for Step Functions to allow it to call Backup and RDS APIs, and read the secret value for validation
data "aws_iam_policy_document" "backup_restore_validation_sfn" {
  statement {
    sid = "BackupRestoreValidation"
    actions = [
      "backup:DescribeRestoreJob",
      "backup:PutRestoreValidationResult"
    ]
    resources = ["*"]
  }

  statement {
    sid = "RdsInstanceLifecycle"
    actions = [
      "rds:CreateDBInstance",
      "rds:DescribeDBInstances",
      "rds:DeleteDBInstance",
      "rds:EnableHttpEndpoint"
    ]
    resources = ["*"]
  }

  statement {
    sid = "RdsDataApi"
    actions = [
      "rds-data:ExecuteStatement"
    ]
    resources = [
      "arn:aws:rds:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster:*"
    ]
  }

  statement {
    sid = "ReadValidationSecret"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      local.restore_validation_secret_arn
    ]
  }
}
