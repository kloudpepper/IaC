############
### NACL ###
############

# Create NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.environment_Name}-public-nacl"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.environment_Name}-private-nacl"
  }
}


# Associate NACL with subnets
resource "aws_network_acl_association" "public_nacl_association" {
  count          = length(var.public_subnet_ids) != 0 ? length(var.public_subnet_ids) : 0
  subnet_id      = var.public_subnet_ids[count.index]
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "private_nacl_association" {
  count          = length(var.private_subnet_ids) != 0 ? length(var.private_subnet_ids) : 0
  subnet_id      = var.private_subnet_ids[count.index]
  network_acl_id = aws_network_acl.private_nacl.id
}

# Create NACL rules
# Public NACL
resource "aws_network_acl_rule" "public_nacl_rule_ingress" {
  network_acl_id = aws_network_acl.public_nacl.id
  egress         = false
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_nacl_rule_egress" {
  network_acl_id = aws_network_acl.public_nacl.id
  egress         = true
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# Private NACL
resource "aws_network_acl_rule" "private_nacl_rule_ingress" {
  network_acl_id = aws_network_acl.private_nacl.id
  egress         = false
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_nacl_rule_egress" {
  network_acl_id = aws_network_acl.private_nacl.id
  egress         = true
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}