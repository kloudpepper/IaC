##################
### ECS Module ###
##################

### CloudWatch Log Groups ###
resource "aws_cloudwatch_log_group" "LogGroupWeb" {
    name = "/ecs/${var.environmentName}-Web"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupApp" {
    name = "/ecs/${var.environmentName}-App"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupDev" {
    name = "/ecs/${var.environmentName}-Dev"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupDevL3" {
    name = "/ecs/${var.environmentName}-DevL3"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupTCUA" {
    name = "/ecs/${var.environmentName}-TCUA"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupBFL" {
    name = "/ecs/${var.environmentName}-BFL"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupBFLMount" {
    name = "/ecs/${var.environmentName}-BFLMount"
    retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "LogGroupBatch" {
    name = "/ecs/${var.environmentName}-Batch"
    retention_in_days = 365
}

### Roles ###
resource "aws_iam_role" "ECSTaskRole" {
  name = "ECSTaskRole-${var.environmentName}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
    ]
  path = "/"
}

resource "aws_iam_role" "ECSTaskExecutionRole" {
  name = "ECSTaskExecutionRole-${var.environmentName}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ]
  path = "/"
}

### Task Definitions ###
resource "aws_ecs_task_definition" "TaskDefinitionWeb" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupWeb]
    family                   = "${var.environmentName}-Web-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "WebContainer",
    "image": "${var.ImageUrlWeb}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-Web",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "Web"
      }
    }
  }
]
TASK_DEFINITION
}

resource "aws_ecs_task_definition" "TaskDefinitionDev" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupDev]
    family                   = "${var.environmentName}-Dev-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "DevContainer",
    "image": "${var.ImageUrlDev}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "LOG_HOME", "value": "/srv/Temenos/iris"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-Dev",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "Dev"
      }
    }
  }
]
TASK_DEFINITION
}

resource "aws_ecs_task_definition" "TaskDefinitionDevL3" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupDevL3]
    family                   = "${var.environmentName}-DevL3-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "DevL3Container",
    "image": "${var.ImageUrlDevL3}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "LOG_HOME", "value": "/srv/Temenos/iris"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-DevL3",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "DevL3"
      }
    }
  }
]
TASK_DEFINITION
}

resource "aws_ecs_task_definition" "TaskDefinitionTCUA" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupTCUA]
    family                   = "${var.environmentName}-TCUA-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "TCUAContainer",
    "image": "${var.ImageUrlTCUA}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-TCUA",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "TCUA"
      }
    }
  }
]
TASK_DEFINITION
}

resource "aws_ecs_task_definition" "TaskDefinitionBFL" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupBFL]
    family                   = "${var.environmentName}-BFL-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "BFLContainer",
    "image": "${var.ImageUrlBFL}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "BFL", "value": "true"},
        {"name": "EXPORT_DESTINATION", "value": "${var.environmentName}-file-export"},
        {"name": "IMPORT_DESTINATION", "value": "${var.environmentName}-file-request"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "mountPoints": [
        {
            "sourceVolume": "import-request",
            "containerPath": "/opt/tocfee/request"
        },
        {
            "sourceVolume": "import-response",
            "containerPath": "/opt/tocfee/response"
        },
        {
            "sourceVolume": "import-error",
            "containerPath": "/opt/tocfee/error"
        }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-BFL",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "BFL"
      }
    }
  }
]
TASK_DEFINITION

    volume {
        name = "import-request"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-request_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "import-response"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-response_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "import-error"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-error_id
                iam                 = "DISABLED"
            }
        }
    }
}

resource "aws_ecs_task_definition" "TaskDefinitionBFLMount" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupBFLMount]
    family                   = "${var.environmentName}-BFLMount-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "BFLContainer",
    "image": "${var.ImageUrlBFL}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "BFL", "value": "true"},
        {"name": "EXPORT_DESTINATION", "value": "${var.environmentName}-file-response"},
        {"name": "IMPORT_DESTINATION", "value": "${var.environmentName}-file-request"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "mountPoints": [
        {
            "sourceVolume": "import-request",
            "containerPath": "/opt/tocfee/request"
        },
        {
            "sourceVolume": "import-response",
            "containerPath": "/opt/tocfee/response"
        },
        {
            "sourceVolume": "import-error",
            "containerPath": "/opt/tocfee/error"
        }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-BFLMount",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "BFLMount"
      }
    }
  }
]
TASK_DEFINITION

    volume {
        name = "import-request"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-request_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "import-response"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-response_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "import-error"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_import-error_id
                iam                 = "DISABLED"
            }
        }
    }
}

resource "aws_ecs_task_definition" "TaskDefinitionApp" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupApp]
    family                   = "${var.environmentName}-App-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "AppContainer",
    "image": "${var.ImageUrlApp}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "DB_USER", "value": "tafj"},
        {"name": "DB_PASSWORD", "value": "tafj"},
        {"name": "DB_URL", "value": "jdbc:oracle:thin:@${var.environmentName}-db.corebancario-diners.com:5960/ORCL4"},
        {"name": "DB_POOL_MIN", "value": "20"},
        {"name": "DB_POOL_MAX", "value": "200"},
        {"name": "DFE_ARCHIVE_DESTINATION", "value": "${var.environmentName}-file-response"},
        {"name": "DFE_EXPORT_DESTINATION", "value": "${var.environmentName}-file-export"},
        {"name": "DFE_IMPORT_DESTINATION", "value": "${var.environmentName}-file-request"},
        {"name": "EXPORT_DESTINATION", "value": "${var.environmentName}-file-export"},
        {"name": "DFE_FOLDERS", "value": "Y"},
        {"name": "IRISUSER", "value": "T24IRISINPUTT"},
        {"name": "IRISPASSWORD", "value": "4$8e.Lhzb6yWvJF("},
        {"name": "TAFJEE_USER", "value": "tafjeeuser"},
        {"name": "TAFJEE_PWD", "value": "Temenos@1234"},
        {"name": "TAFJEE_ROLE", "value": "TAFJAdmin"},
        {"name": "MDB_POOL_MAX", "value": "20"},
        {"name": "DBToolsuser", "value": "tafjuser"},
        {"name": "DBToolspassword", "value": "Temenos_123"},
        {"name": "LOG4J_FORMAT_MSG_NO_LOOKUPS", "value": "true"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "mountPoints": [
        {
            "sourceVolume": "dw-export",
            "containerPath": "/srv/Temenos/tos3"
        },
        {
            "sourceVolume": "dfe",
            "containerPath": "/srv/Temenos/T24/Lib/UD/DFE"
        },
        {
            "sourceVolume": "udexternal",
            "containerPath": "/srv/Temenos/T24/UDExternal"
        },
        {
            "sourceVolume": "cfrextract",
            "containerPath": "/srv/Temenos/T24/Lib/UD/FBNK.RE.CRF.EXTRACT"
        },
        {
            "sourceVolume": "tafj_log",
            "containerPath": "/srv/Temenos/TAFJ/log"
        },
        {
            "sourceVolume": "tafj_logt24",
            "containerPath": "/srv/Temenos/TAFJ/log_T24"
        }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-App",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "App"
      }
    }
  }
]
TASK_DEFINITION

    volume {
        name = "dw-export"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_dw-export_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "dfe"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_dfe_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "udexternal"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_udexternal_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "cfrextract"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_cfrextract_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "tafj_log"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_TAFJ_log_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "tafj_logt24"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_TAFJ_logT24_id
                iam                 = "DISABLED"
            }
        }
    }
}

resource "aws_ecs_task_definition" "TaskDefinitionBatch" {
    depends_on               = [aws_cloudwatch_log_group.LogGroupBatch]
    family                   = "${var.environmentName}-Batch-TD"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 2048
    memory                   = 12288
    task_role_arn            = aws_iam_role.ECSTaskRole.arn
    execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "BatchContainer",
    "image": "${var.ImageUrlBatch}",
    "portMappings": [
        {
            "containerPort": 8443,
            "hostPort": 8443
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "${var.MQUser}"},
        {"name": "JMS_PASSWORD", "value": "${var.MQPassword}"},
        {"name": "JMS_URL", "value": "${var.MQEnpointAddr}"},
        {"name": "DB_USER", "value": "tafj"},
        {"name": "DB_PASSWORD", "value": "tafj"},
        {"name": "DB_URL", "value": "jdbc:oracle:thin:@${var.environmentName}-db.corebancario-diners.com:5960/ORCL4"},
        {"name": "DB_POOL_MIN", "value": "20"},
        {"name": "DB_POOL_MAX", "value": "200"},
        {"name": "DFE_ARCHIVE_DESTINATION", "value": "${var.environmentName}-file-response"},
        {"name": "DFE_EXPORT_DESTINATION", "value": "${var.environmentName}-file-export"},
        {"name": "DFE_IMPORT_DESTINATION", "value": "${var.environmentName}-file-request"},
        {"name": "EXPORT_DESTINATION", "value": "${var.environmentName}-file-export"},
        {"name": "temn.tafj.appserver.start.tsa", "value": "8"},
        {"name": "WEB_URL", "value": "${var.environmentName}.corebancario-diners.com"},
        {"name": "DFE_FOLDERS", "value": "Y"},
        {"name": "IRISUSER", "value": "T24IRISINPUTT"},
        {"name": "IRISPASSWORD", "value": "4$8e.Lhzb6yWvJF("},
        {"name": "TAFJEE_USER", "value": "tafjeeuser"},
        {"name": "TAFJEE_PWD", "value": "Temenos@1234"},
        {"name": "TAFJEE_ROLE", "value": "TAFJAdmin"},
        {"name": "MDB_POOL_MAX", "value": "20"},
        {"name": "DBToolsuser", "value": "tafjuser"},
        {"name": "DBToolspassword", "value": "Temenos_123"},
        {"name": "LOG4J_FORMAT_MSG_NO_LOOKUPS", "value": "true"},
        {"name": "TZ", "value": "America/Guayaquil"}
    ],
    "mountPoints": [
        {
            "sourceVolume": "dw-export",
            "containerPath": "/srv/Temenos/tos3"
        },
        {
            "sourceVolume": "dfe",
            "containerPath": "/srv/Temenos/T24/Lib/UD/DFE"
        },
        {
            "sourceVolume": "udexternal",
            "containerPath": "/srv/Temenos/T24/UDExternal"
        },
        {
            "sourceVolume": "cfrextract",
            "containerPath": "/srv/Temenos/T24/Lib/UD/FBNK.RE.CRF.EXTRACT"
        },
        {
            "sourceVolume": "tafj_log",
            "containerPath": "/srv/Temenos/TAFJ/log"
        },
        {
            "sourceVolume": "tafj_logt24",
            "containerPath": "/srv/Temenos/TAFJ/log_T24"
        }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65535,
        "hardLimit": 65535
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.environmentName}-Batch",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "Batch"
      }
    }
  }
]
TASK_DEFINITION

    volume {
        name = "dw-export"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_dw-export_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "dfe"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_dfe_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "udexternal"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_udexternal_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "cfrextract"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_cfrextract_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "tafj_log"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_TAFJ_log_id
                iam                 = "DISABLED"
            }
        }
    }
    volume {
        name = "tafj_logt24"
        efs_volume_configuration {
            file_system_id          = var.EFSFileSystem_id
            transit_encryption      = "ENABLED"
            authorization_config {
                access_point_id     = var.AccessPoint_TAFJ_logT24_id
                iam                 = "DISABLED"
            }
        }
    }
}

### Cluster ###
resource "aws_ecs_cluster" "ECSCluster" {
    name = "${var.environmentName}-cluster"
    setting {
      name  = "containerInsights"
      value = "enabled"
    }
}

### Services ###
resource "aws_ecs_service" "ServiceWeb" {
    name = "${var.environmentName}-web"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = var.TargetGroupWEB_arn
        container_name = "WebContainer"
        container_port = 8443
    }
    health_check_grace_period_seconds = 60
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionWeb.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceDev" {
    name = "${var.environmentName}-dev"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = var.TargetGroupDEV_arn
        container_name = "DevContainer"
        container_port = 8443
    }
    health_check_grace_period_seconds = 60
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionDev.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceDevL3" {
    name = "${var.environmentName}-devL3"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = var.TargetGroupDEVL3_arn
        container_name = "DevL3Container"
        container_port = 8443
    }
    health_check_grace_period_seconds = 60
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionDevL3.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceTCUA" {
    name = "${var.environmentName}-tcua"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = var.TargetGroupTCUA_arn
        container_name = "TCUAContainer"
        container_port = 8443
    }
    health_check_grace_period_seconds = 60
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionTCUA.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceBFL" {
    name = "${var.environmentName}-bfl"
    cluster = aws_ecs_cluster.ECSCluster.id
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionBFL.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceBFLMount" {
    name = "${var.environmentName}-bflmount"
    cluster = aws_ecs_cluster.ECSCluster.id
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionBFLMount.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceApp" {
    name = "${var.environmentName}-app"
    cluster = aws_ecs_cluster.ECSCluster.id
    load_balancer {
        target_group_arn = var.TargetGroupAPP_arn
        container_name = "AppContainer"
        container_port = 8443
    }
    health_check_grace_period_seconds = 60
    desired_count = var.DesiredCount
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionApp.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}

resource "aws_ecs_service" "ServiceBatch" {
    name = "${var.environmentName}-batch"
    cluster = aws_ecs_cluster.ECSCluster.id
    desired_count = 0
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.TaskDefinitionBatch.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = false
        security_groups = [var.ECSSecurityGroup_id]
        subnets = [var.PrivateSubnet1_id,var.PrivateSubnet2_id]
    }
    scheduling_strategy = "REPLICA"
    enable_execute_command = true
    enable_ecs_managed_tags = true
    propagate_tags = "SERVICE"
    force_new_deployment = true
}