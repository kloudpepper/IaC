# AWS Backup - Restore Testing for Aurora
# Plan
resource "aws_backup_restore_testing_plan" "aurora" {
  name                         = "aurora_restore_test"
  schedule_expression          = "cron(40 18 ? * SAT *)"
  schedule_expression_timezone = "Europe/Madrid"
  start_window_hours           = 1

  recovery_point_selection {
    algorithm             = "LATEST_WITHIN_WINDOW"
    include_vaults        = ["*"] # Consider scoping this down to specific vaults if you have multiple vaults in the account
    recovery_point_types  = ["SNAPSHOT"]
    selection_window_days = 1
  }

  tags = var.tags
}

# Selection for Aurora resources to restore, with metadata overrides to ensure the restored instance can be created in the same VPC and subnets as the original, and use the same KMS key for encryption
resource "aws_backup_restore_testing_selection" "aurora" {
  name                      = "aurora_selection"
  restore_testing_plan_name = aws_backup_restore_testing_plan.aurora.name
  protected_resource_type   = "Aurora"
  iam_role_arn              = aws_iam_role.backup_restore_testing_aurora.arn

  protected_resource_arns = [
    module.cluster.cluster_arn
  ]

  restore_metadata_overrides = {
    dbSubnetGroupName           = module.cluster.db_subnet_group_name
    dbClusterParameterGroupName = module.cluster.db_cluster_parameter_group_id
    vpcSecurityGroupIds         = jsonencode([module.sg_aurora.security_group_id])
    kmsKeyId                    = module.kms_aurora.key_arn
    port                        = module.cluster.cluster_port
    engineVersion               = module.cluster.cluster_engine_version_actual
  }

  validation_window_hours = 1
}

# Role for Backup to assume when performing the restore
data "aws_iam_policy_document" "backup_restore_testing_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup_restore_testing_aurora" {
  name               = "aws-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_restore_testing_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "backup_restore_testing_backup_policy" {
  role       = aws_iam_role.backup_restore_testing_aurora.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore_testing_restore_policy" {
  role       = aws_iam_role.backup_restore_testing_aurora.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}
