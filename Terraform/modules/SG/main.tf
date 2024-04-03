##############################
### Security Groups Module ###
##############################

locals {
  ports = {
    http     = 80
    https    = 443
    mq       = 61617
    postgres = 5432
  }
}

# Create ALB Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-alb-sg"
  description = "ALB Security Group"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
    from_port   = local.ports.http
    to_port     = local.ports.http
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
    from_port   = local.ports.https
    to_port     = local.ports.https
    protocol    = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-alb-sg"
  }
}

# Create ECS Security Group
resource "aws_security_group" "ecs_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-ecs-sg"
  description = "ECS Security Group"

  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    description     = ""
    from_port       = local.ports.http
    to_port         = local.ports.http
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-ecs-sg"
  }
}

# Create MQ Security Group
resource "aws_security_group" "mq_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-mq-sg"
  description = "MQ Security Group"

  ingress {
    security_groups = [aws_security_group.ecs_sg.id]
    description     = ""
    from_port       = local.ports.mq
    to_port         = local.ports.mq
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-mq-sg"
  }
}

# Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-rds-sg"
  description = "RDS Security Group"

  ingress {
    security_groups = [aws_security_group.ecs_sg.id]
    description     = ""
    from_port       = local.ports.postgres
    to_port         = local.ports.postgres
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-rds-sg"
  }
}

# Create VPC Endpoints Security Group
resource "aws_security_group" "vpc_endpoint_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-vpcendpoints-sg"
  description = "VPC Endpoints Security Group"

  ingress {
    cidr_blocks = [var.vpc_CIDR]
    description = ""
    from_port   = local.ports.https
    to_port     = local.ports.https
    protocol    = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-vpcendpoints-sg"
  }
}