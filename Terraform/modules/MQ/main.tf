#################
### MQ Module ###
#################

resource "aws_mq_configuration" "ConfigurationMQ" {
  description    = "MQ Configuration"
  name           = "${var.environmentName}-Configuration-MQ"
  engine_type    = "ActiveMQ"
  engine_version = "5.17.2"
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

resource "aws_mq_broker" "ApacheMQ" {
  broker_name = "${var.environmentName}-MQ"
  configuration {
    id       = aws_mq_configuration.ConfigurationMQ.id
    revision = aws_mq_configuration.ConfigurationMQ.latest_revision
  }
  engine_type                = "ActiveMQ"
  engine_version             = "5.17.2"
  storage_type               = "ebs"
  host_instance_type         = "mq.m5.large"
  deployment_mode            = "SINGLE_INSTANCE"
  publicly_accessible        = false
  subnet_ids                 = [var.PrivateSubnet1_id]
  security_groups            = [var.MQSecurityGroup_id]
  apply_immediately          = true
  auto_minor_version_upgrade = true
  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "America/Guayaquil"
  }
  logs {
    general = true
    audit   = false
  }
  user {
    console_access = true
    username       = var.MQUser
    password       = var.MQPassword
  }
}