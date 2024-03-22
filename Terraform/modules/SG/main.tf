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
  name        = "${var.environment_Name}-ALB-SG"
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
    Name = "${var.environment_Name}-ALB-SG"
  }
}

# Create EKS Security Group
resource "aws_security_group" "eks_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-EKS-SG"
  description = "EKS Security Group"

  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    description     = ""
    from_port       = local.ports.http
    to_port         = local.ports.http
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-EKS-SG"
  }
}

# Create MQ Security Group
resource "aws_security_group" "mq_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-MQ-SG"
  description = "MQ Security Group"

  ingress {
    security_groups = [aws_security_group.eks_sg.id]
    description     = ""
    from_port       = local.ports.mq
    to_port         = local.ports.mq
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-MQ-SG"
  }
}

# Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-RDS-SG"
  description = "RDS Security Group"

  ingress {
    security_groups = [aws_security_group.eks_sg.id]
    description     = ""
    from_port       = local.ports.postgres
    to_port         = local.ports.postgres
    protocol        = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-RDS-SG"
  }
}

# Create VPC Endpoints Security Group
resource "aws_security_group" "vpc_endpoint_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment_Name}-VPCEndpoints-SG"
  description = "VPC Endpoints Security Group"

  ingress {
    cidr_blocks = [var.vpc_CIDR]
    description = ""
    from_port   = local.ports.https
    to_port     = local.ports.https
    protocol    = "tcp"
  }

  tags = {
    Name = "${var.environment_Name}-VPCEndpoints-SG"
  }
}