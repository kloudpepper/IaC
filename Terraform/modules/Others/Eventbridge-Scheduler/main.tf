###############
## Schedules ##
###############

# - Stop Aurora Cluster
resource "aws_scheduler_schedule" "stop_aurora_cluster" {
  name                         = "stop_aurora_cluster"
  description                  = "A scheduler to stop the Aurora Cluster"
  state                        = "ENABLED"
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 18 ? * 2-6 *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.eventbridge_role.arn
    input = jsonencode({
      DocumentName = "AWS-StartStopAuroraCluster",
      Parameters = {
        ClusterName          = [kloudpepper-cluster],
        Action               = ["Stop"],
        AutomationAssumeRole = [aws_iam_role.ssm_automation_role.arn]
      }
    })
    retry_policy {
      maximum_event_age_in_seconds = 600
      maximum_retry_attempts       = 0
    }
  }
}

# - Start Aurora Cluster
resource "aws_scheduler_schedule" "start_aurora_cluster" {
  name                         = "start_aurora_cluster"
  description                  = "A scheduler to start the Aurora Cluster"
  state                        = "ENABLED"
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 7 ? * 2-6 *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.eventbridge_role.arn
    input = jsonencode({
      DocumentName = "AWS-StartStopAuroraCluster",
      Parameters = {
        ClusterName          = [kloudpepper-cluster],
        Action               = ["Start"],
        AutomationAssumeRole = [aws_iam_role.ssm_automation_role.arn]
      }
    })
    retry_policy {
      maximum_event_age_in_seconds = 600
      maximum_retry_attempts       = 0
    }
  }
}

###########
## Roles ##
###########
# - Role for EventBridge Scheduler
resource "aws_iam_role" "eventbridge_role" {
  name = "Eventbridge_Role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  tags = {
    "Name" = "Eventbridge_Role"
  }
}

# - Role for SSM Automation
resource "aws_iam_role" "ssm_automation_role" {
  name = "SSMAutomation_Role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  tags = {
    "Name" = "SSMAutomation_Role"
  }
}

##############
## Policies ##
##############
# - Policy to start Automation Execution
resource "aws_iam_policy" "ssm_automation_eventbridge_policy" {
  name = "ssm_automation_eventbridge_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:StartAutomationExecution"
        ],
        "Resource" : [
          "*"
        ],
        "Sid" : "StartAutomationExecution"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : [
          aws_iam_role.ssm_automation_role.arn
        ],
        "Sid" : "PassRoleToTaskRoles"
      }
    ]
  })

  tags = {
    "Name" = "ssm_automation_eventbridge_policy"
  }
}

# - Policy to Start Stop Aurora Cluster
resource "aws_iam_policy" "start_stop_aurora_policy" {
  name = "start_stop_aurora_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:StartDBCluster",
          "rds:StopDBCluster",
          "rds:DescribeDBClusters"
        ],
        "Resource" : [
          "*"
        ],
        "Sid" : "StartStopAurora"
      }
    ]
  })

  tags = {
    "Name" = "start_stop_aurora_policy"
  }
}

################################
# Attach policies to the roles #
################################
resource "aws_iam_role_policy_attachments_exclusive" "eventbridge_policy-attachments" {
  role_name = aws_iam_role.eventbridge_role.name
  policy_arns = [
    aws_iam_policy.ssm_automation_eventbridge_policy.arn
  ]
}

resource "aws_iam_role_policy_attachments_exclusive" "ssm_automation_policy-attachments" {
  role_name = aws_iam_role.ssm_automation_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole",
    aws_iam_policy.start_stop_aurora_policy.arn
  ]
}