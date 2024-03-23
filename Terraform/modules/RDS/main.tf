##################
### RDS Module ###
##################

resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.environment_Name}-subnetgroup"
  description = "Private subnet group for the database"
  subnet_ids  = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 1, 3) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 1, 3, 5) : var.private_subnet_ids
  tags = {
    "Name" = "${var.environment_Name}-subnetgroup"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = "${var.environment_Name}-parametergroup"
  description = "${var.environment_Name}-postgres-16"
  family      = "postgres16"
  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }
  tags = {
    "Name" = "${var.environment_Name}-parametergroup"
  }
}

resource "aws_db_instance" "postgres_db" {
  identifier            = "${var.environment_Name}-db"
  engine                = "postgres"
  engine_version        = "16"
  instance_class        = "db.t3.micro"
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp2"
  db_name                         = "KLOUDPEPPERDB"
  port                            = 5432
  vpc_security_group_ids          = [var.rds_sg_id]
  db_subnet_group_name            = "${var.environment_Name}-subnetgroup"
  parameter_group_name            = "${var.environment_Name}-parametergroup"
  multi_az                        = false
  publicly_accessible             = false
  auto_minor_version_upgrade      = true
  maintenance_window              = "Sun:06:00-Sun:06:30"
  backup_window                   = "07:30-08:00"
  backup_retention_period         = 30
  copy_tags_to_snapshot           = true
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["alert", "audit", "listener", "trace"]
  apply_immediately               = true
  skip_final_snapshot             = true
  deletion_protection             = false
  #kms_key_id              = aws_kms_key.aurora_db.arn
  #username                = "master"
  #password                = data.aws_secretsmanager_secret_version.password.secret_string
  timeouts {
    create = "60m"
    delete = "30m"
    update = "60m"
  }
}


# #################
# ## DB PASSWORD ##
# # Genarates a random password and then store it in SSM parameter store
# #################

# data "aws_secretsmanager_secret" "name" {
#   name       = "/${var.environment}/rds/${var.name}/master"
#   depends_on = [null_resource.random-pw]
# }

# data "aws_secretsmanager_secret_version" "password" {
#   secret_id = "${data.aws_secretsmanager_secret.name.id}"
# }

# resource "null_resource" "random-pw" {

#   provisioner "local-exec" {
#     command = "aws secretsmanager create-secret --name \"/${var.environment}/rds/${var.name}/master\" --secret-string `openssl rand -base64 32 | cut -c1-32 | tr '/@' '_'`  --kms-key-id ${aws_kms_key.aurora_db.arn} "
#   }

#   provisioner "local-exec" {
#     command =  "aws secretsmanager delete-secret --secret-id \"/${var.environment}/rds/${var.name}/master\"  --force-delete-without-recovery"
#     when    =  destroy
#   }
# }

# ####### RDS KMS Encryption ########

# data "aws_caller_identity" "current" {}

# resource "aws_kms_key" "aurora_db" {
#   description         = "${var.environment}/rds/${var.environment}-${var.name}"
#   enable_key_rotation = true

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "key-consolepolicy-3",
#   "Statement": [
#     {
#       "Sid": "Enable IAM User Permissions",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       },
#       "Action": "kms:*",
#       "Resource": "*"
#     },
#     {
#       "Sid": "Allow access for Key Administrators",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${data.aws_caller_identity.current.arn}"
#       },
#       "Action": [
#         "kms:Create*",
#         "kms:Describe*",
#         "kms:Enable*",
#         "kms:List*",
#         "kms:Put*",
#         "kms:Update*",
#         "kms:Revoke*",
#         "kms:Disable*",
#         "kms:Get*",
#         "kms:Delete*",
#         "kms:TagResource",
#         "kms:UntagResource",
#         "kms:ScheduleKeyDeletion",
#         "kms:CancelKeyDeletion"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Sid": "Allow use of the key",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${data.aws_caller_identity.current.arn}"
#       },
#       "Action": [
#         "kms:Encrypt",
#         "kms:Decrypt",
#         "kms:ReEncrypt*",
#         "kms:GenerateDataKey*",
#         "kms:DescribeKey"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Sid": "Allow attachment of persistent resources",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "${data.aws_caller_identity.current.arn}"
#       },
#       "Action": [
#         "kms:CreateGrant",
#         "kms:ListGrants",
#         "kms:RevokeGrant"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "Bool": {
#           "kms:GrantIsForAWSResource": "true"
#         }
#       }
#     }
#   ]
# }
# POLICY
# }

# resource "aws_kms_alias" "aurora_db" {
#   name          = "alias/${var.environment}/rds/${var.name}"
#   target_key_id = aws_kms_key.aurora_db.key_id
# }