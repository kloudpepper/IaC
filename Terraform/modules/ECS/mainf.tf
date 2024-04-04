##################
### ECS Module ###
##################

locals {
  containers = ["web", "app"]
}

### CloudWatch Log Groups ###
resource "aws_cloudwatch_log_group" "log_group" {
  for_each          = toset(local.containers)
  name              = "/ecs/${var.environment_Name}-${each.value}"
  retention_in_days = 7
}

### Roles ###
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment_Name}-ECSTaskRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  path = "/"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment_Name}-ECSTaskExecutionRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
  path = "/"
}

### Task Definitions ###
resource "aws_ecs_task_definition" "task_definition" {
  for_each                 = toset(local.containers)
  family                   = "${var.environment_Name}-${each.value}-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${each.value}-container",
    "image": "${var.docker_image}",
    "portMappings": [
        {
            "containerPort": 80,
            "hostPort": 80
        }
    ],
    "environment": [
        {"name": "JMS_USER", "value": "master"},
        {"name": "JMS_URL", "value": "${var.mq_endpoint}"},
        {"name": "TZ", "value": "Europe/Paris"}
    ],
    "secrets": [
        {
            "name": "JMS_PASSWORD",
            "valueFrom": "${var.mq_password_arn}"
        },
        {
            "name": "DB_URL",
            "valueFrom": "${var.db_url}"
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
        "awslogs-group": "/ecs/${var.environment_Name}-${each.value}",
        "awslogs-region": "${var.aws_Region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION
}


### Cluster ###
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment_Name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  service_connect_defaults {
    namespace = var.http_namespace_arn
  }
}

### Services ###
resource "aws_ecs_service" "ecs_service" {
  for_each = toset(local.containers)
  name     = "${var.environment_Name}-${each.value}-service"
  cluster  = aws_ecs_cluster.ecs_cluster.id
  load_balancer {
    target_group_arn = each.key == "web" ? var.web_target_group_arn : var.app_target_group_arn
    container_name   = "${each.value}-container"
    container_port   = 80
  }
  health_check_grace_period_seconds = 60
  desired_count                     = 1
  #launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  task_definition                    = aws_ecs_task_definition.task_definition[each.key].arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    assign_public_ip = false
    security_groups  = [var.ecs_sg_id]
    subnets          = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 0, 2) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 0, 2, 4) : var.private_subnet_ids
  }
  scheduling_strategy     = "REPLICA"
  enable_execute_command  = true
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  force_new_deployment    = true
  service_connect_configuration {
    namespace = var.http_namespace_arn
    enabled   = true
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 2
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 2
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}