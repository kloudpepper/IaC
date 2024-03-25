#################
### DB Module ###
#################

#########
## RDS ##
#########

# Create subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.environment_Name}-subnetgroup"
  description = "Private subnet group for the database"
  subnet_ids  = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 1, 3) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 1, 3, 5) : var.private_subnet_ids
  tags = {
    "Name" = "${var.environment_Name}-subnetgroup"
  }
}

# Create parameter group
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

# Create RDS Instance
resource "aws_db_instance" "postgres_db" {
  identifier                      = "${var.environment_Name}-db"
  engine                          = "postgres"
  engine_version                  = "16"
  instance_class                  = "db.t3.micro"
  allocated_storage               = 20
  max_allocated_storage           = 1000
  storage_type                    = "gp2"
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
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  apply_immediately               = true
  skip_final_snapshot             = true
  deletion_protection             = false
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.db_postgres.arn
  username                        = "master"
  password                        = aws_secretsmanager_secret_version.db_password.secret_string
  timeouts {
    create = "60m"
    delete = "30m"
    update = "60m"
  }
  tags = {
    "Name" = "${var.environment_Name}-db"
  }
}


#####################
## Secrets Manager ##
#####################

# Create and store DB password (Secrets Manager)
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%+=.,;:!"
}

resource "aws_secretsmanager_secret" "db_password" {
  name       = "/${var.environment_Name}/rds/postgres/master"
  kms_key_id = aws_kms_key.db_password.arn
  tags = {
    "Name" = "${var.environment_Name}-db_password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.password.result
}


#########
## KMS ##
#########

provider "aws" {
  alias  = "replica"
  region = "us-west-2" # Change this to the region where you want to create the replica key
}

# Create a KMS key -- DB storage encryption
resource "aws_kms_key" "db_postgres" {
  description             = "${var.environment_Name}/rds/postgres/${var.environment_Name}-db"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  multi_region            = true
  tags = {
    "Name" = "${var.environment_Name}-db"
  }
}

resource "aws_kms_replica_key" "db_replica" {
  provider                = aws.replica
  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = aws_kms_key.db_postgres.arn
}

resource "aws_kms_alias" "db_alias" {
  name          = "alias/${var.environment_Name}-db"
  target_key_id = aws_kms_key.db_postgres.id
}


# Create a KMS key -- DB password encryption
resource "aws_kms_key" "db_password" {
  description             = "${var.environment_Name}/rds/postgres/${var.environment_Name}-db_password"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  multi_region            = true
  tags = {
    "Name" = "${var.environment_Name}-db_password"
  }
}

resource "aws_kms_replica_key" "db_password_replica" {
  provider                = aws.replica
  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = aws_kms_key.db_password.arn
}

resource "aws_kms_alias" "db_password_alias" {
  name          = "alias/${var.environment_Name}-db_password"
  target_key_id = aws_kms_key.db_password.id
}