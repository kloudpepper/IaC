##################
### RDS Module ###
##################

resource "aws_db_subnet_group" "RDSsubnetgroup" {
    name        = "${var.environmentName}-subnetgroup"
    description = "Subnet Group para la base de datos RDS - 2 subredes"
    subnet_ids  = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    tags =  {
        "Name" = "${var.environmentName}-subnetgroup"
    }
}

/* resource "aws_db_option_group" "RDSoptiongroup" {
    name                     = "${var.environmentName}-optiongroup"
    option_group_description = "${var.environmentName}-oracle-19"
    engine_name              = "oracle-ee"
    major_engine_version     = "19"
    option {
        option_name = "Timezone"
        option_settings {
            name  = "TIME_ZONE"
            value = "America/Bogota"
        }
    }
    option {
        option_name = "S3_INTEGRATION"
        version  = "1.0"
    }
    option {
        option_name = "JVM"
    }
    tags =  {
        "Name" = "${var.environmentName}-optiongroup"
    }
} */

resource "aws_db_parameter_group" "RDSparametergroup" {
    name        = "${var.environmentName}-parametergroup"
    description = "${var.environmentName}-oracle-19"
    family      = "oracle-ee-19"
    parameter {
        name  = "control_management_pack_access"
        value = "NONE"
    }
    parameter {
        name = "enable_goldengate_replication"
        value = "TRUE"
    }
    tags = {
      "Name" = "${var.environmentName}-parametergroup"
    }
}

resource "aws_db_instance" "RDSInstance" {
    identifier              = "${var.environmentName}-db"
    engine                  = "oracle-ee"
    #engine_version          = "19.0.0.0.ru-2022-07.rur-2022-07.r1"
    instance_class          = "db.r5.large"
    #allocated_storage       = 100
    #max_allocated_storage   = 1000
    #storage_type           = io1
    #iops                   = 1000
    db_name                 = "ORCL4"
    port                    = 5960
    vpc_security_group_ids = [var.RDSSecurityGroup_id]
    db_subnet_group_name   = "${var.environmentName}-subnetgroup"
    parameter_group_name   = "${var.environmentName}-parametergroup"
    #option_group_name      = "${var.environmentName}-optiongroup"
    multi_az               = false
    publicly_accessible    = false
    auto_minor_version_upgrade  = true
    maintenance_window          = "Sun:06:00-Sun:06:30"
    #backup_window = "07:30-08:00"
    backup_retention_period = 2
    snapshot_identifier       = var.snapshot_ARN
    copy_tags_to_snapshot     = true
    storage_encrypted = true
    enabled_cloudwatch_logs_exports = ["alert", "audit", "listener", "trace"]
    apply_immediately = true
    skip_final_snapshot = true
    deletion_protection      = false
    timeouts {
        create = "60m"
        delete = "30m"
        update = "60m"
    }
}