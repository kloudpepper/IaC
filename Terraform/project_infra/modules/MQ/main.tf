#################
### MQ Module ###
#################

# Create a MQ configuration
resource "aws_mq_configuration" "configuration" {
  description    = "MQ Configuration"
  name           = "${var.environment_Name}-configuration-mq"
  engine_type    = "ActiveMQ"
  engine_version = "5.17.6"
  data           = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker advisorySupport="false" deleteAllMessagesOnStartup="true" schedulePeriodForDestinationPurge="10000" xmlns="http://activemq.apache.org/schema/core">
  <persistenceAdapter>
    <kahaDB concurrentStoreAndDispatchQueues="false"/>
  </persistenceAdapter>
  <destinationPolicy>
    <policyMap>
      <policyEntries>
        <policyEntry gcInactiveDestinations="true" inactiveTimoutBeforeGC="600000" topic="&gt;">
          <pendingMessageLimitStrategy>
            <constantPendingMessageLimitStrategy limit="1000"/>
          </pendingMessageLimitStrategy>
        </policyEntry>
        <policyEntry gcInactiveDestinations="true" inactiveTimoutBeforeGC="600000" queue="&gt;"/>
      </policyEntries>
    </policyMap>
  </destinationPolicy>
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
  </plugins>
</broker>
DATA
}

# Create a MQ broker
resource "aws_mq_broker" "apache_mq" {
  broker_name = "${var.environment_Name}-apache-mq"
  configuration {
    id       = aws_mq_configuration.configuration.id
    revision = aws_mq_configuration.configuration.latest_revision
  }
  engine_type                = "ActiveMQ"
  engine_version             = "5.17.6"
  storage_type               = "efs"
  host_instance_type         = "mq.t3.micro"
  deployment_mode            = "SINGLE_INSTANCE"
  publicly_accessible        = false
  subnet_ids                 = [var.private_subnet_ids[0]]
  security_groups            = [var.mq_sg_id]
  apply_immediately          = true
  auto_minor_version_upgrade = false
  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "02:00"
    time_zone   = "Europe/Paris"
  }
  logs {
    general = true
    audit   = false
  }
  user {
    console_access = true
    username       = "master"
    password       = random_password.password.result
  }
  encryption_options {
    kms_key_id        = aws_kms_key.mq_key.arn
    use_aws_owned_key = false
  }
  tags = {
    "Name" = "${var.environment_Name}-apache-mq"
  }
}


# Create a KMS key -- MQ storage encryption
resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_kms_key" "mq_key" {
  description             = "${var.environment_Name}/mq/apachemq/${random_string.random.result}/${var.environment_Name}-mq-key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  multi_region            = true
  tags = {
    "Name" = "${var.environment_Name}-mq-key"
  }
}

resource "aws_kms_alias" "mq_alias" {
  name          = "alias/${var.environment_Name}-mq-key"
  target_key_id = aws_kms_key.mq_key.id
}



# Create a random password for the MQ user
resource "random_password" "password" {
  length           = 12
  special          = true
  override_special = "!@#$%&/()[]{}-?" # Exclude the characters [, :=]
}


# Store MQ password (Secrets Manager)
resource "aws_secretsmanager_secret" "mq_password" {
  name = "/${var.environment_Name}/mq/apachemq/${random_string.random.result}/master"
  tags = {
    "Name" = "${var.environment_Name}-mq_password"
  }
}

resource "aws_secretsmanager_secret_version" "mq_password" {
  secret_id     = aws_secretsmanager_secret.mq_password.id
  secret_string = random_password.password.result
}