##############################
### Security Groups Module ###
##############################

# Create Lambda Security Group
resource "aws_security_group" "LambdaSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-Lambda-SG"
  description       = "Lambda Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  tags = {
        Name        = "${var.environmentName}-Lambda-SG"
  }
}

# Create SFTP Security Group
resource "aws_security_group" "SFTPSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-SFTP-SG"
  description       = "SFTP Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-SFTP-SG"
  }
}

# Create ALB Security Group
resource "aws_security_group" "ALBSecurityGroup" {
  depends_on        = [aws_security_group.LambdaSecurityGroup]
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-ALB-SG"
  description       = "ALB Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  ingress {
    cidr_blocks     = ["10.1.155.146/32"]
    description     = "from Bastion ATOMA"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  ingress {
    security_groups = [aws_security_group.LambdaSecurityGroup.id]
    description     = "from Lambdas"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-ALB-SG"
  }
}

# Create ECS Security Group
resource "aws_security_group" "ECSSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-ECS-SG"
  description       = "ECS Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    security_groups = [aws_security_group.ALBSecurityGroup.id]
    description     = "from ALB"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-ECS-SG"
  }
}

# Create MQ Security Group
resource "aws_security_group" "MQSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-MQ-SG"
  description       = "MQ Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    security_groups = [aws_security_group.ECSSecurityGroup.id]
    description     = "from ECS"
    from_port       = 61617
    to_port         = 61617
    protocol        = "tcp"
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 61617
    to_port         = 61617
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-MQ-SG"
  }
}

# Create RDS Security Group
resource "aws_security_group" "RDSSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-RDS-SG"
  description       = "RDS Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    security_groups = [aws_security_group.ECSSecurityGroup.id]
    description     = "from ECS"
    from_port       = 5960
    to_port         = 5960
    protocol        = "tcp"
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 5960
    to_port         = 5960
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-RDS-SG"
  }
}

# Create EFS Security Group
resource "aws_security_group" "EFSSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-EFS-SG"
  description       = "EFS Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    security_groups = [aws_security_group.ECSSecurityGroup.id]
    description     = "from ECS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  ingress {
    cidr_blocks     = ["10.1.146.247/32"]
    description     = "from Bastion Kyndryl"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-EFS-SG"
  }
}

# Create VPC Endpoints Security Group
resource "aws_security_group" "VPCEnpointSecurityGroup" {
  vpc_id            = var.vpc_id
  name              = "${var.environmentName}-VPCEndpoints-SG"
  description       = "VPC Endpoints Security Group"

  egress {
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    protocol        = -1
  }

  ingress {
    cidr_blocks     = [var.vpc_CIDR]
    description     = "from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
  }

  tags = {
        Name        = "${var.environmentName}-VPCEndpoints-SG"
  }
}