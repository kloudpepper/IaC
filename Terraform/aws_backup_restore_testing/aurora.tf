# Aurora cluster
module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "aurora-cluster"
  engine         = "aurora-postgresql"
  engine_version = "17.9"

  cluster_instance_class = "db.r6g.large"
  instances = {
    one = {}
  }

  database_name = "PETS"

  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  create_db_subnet_group = true
  db_subnet_group_name   = "subnet-group"

  create_security_group  = false
  vpc_security_group_ids = [module.sg_aurora.security_group_id]

  cluster_parameter_group = {
    name            = "cluster-parameter-group"
    use_name_prefix = false
    family          = "aurora-postgresql17"
  }

  master_username                     = "postgres"
  manage_master_user_password         = true
  iam_database_authentication_enabled = true
  enable_http_endpoint                = true # RDS Data API

  storage_encrypted = true
  kms_key_id        = module.kms_aurora.key_arn

  enabled_cloudwatch_logs_exports = ["postgresql"]

  skip_final_snapshot = true

  apply_immediately = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# KMS key for Aurora cluster encryption
module "kms_aurora" {
  source = "terraform-aws-modules/kms/aws"

  description             = "Aurora Cluster key usage"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  # Policy
  enable_default_policy = true

  # Aliases
  aliases = ["kms/aurora"]

  tags = var.tags
}

# Security group for Aurora Instances
module "sg_aurora" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "cluster-sg"
  description     = "Security group for Aurora instances"
  use_name_prefix = false
  vpc_id          = module.vpc.vpc_id

  # Ingress rules
  # ingress_with_source_security_group_id = [
  #   {
  #     from_port                = 
  #     to_port                  = 
  #     protocol                 = "tcp"
  #     description              = ""
  #     source_security_group_id = 
  #   }
  # ]

  # Egress rules
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.tags
}
