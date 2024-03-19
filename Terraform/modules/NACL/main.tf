############
### NACL ###
############
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


resource "aws_network_acl_association" "public_nacl_association" {
  subnet_id      = var.public_subnet_ids
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "private_nacl_association" {
  subnet_id      = var.private_subnet_ids
  network_acl_id = aws_network_acl.private_nacl.id
}




# resource "aws_network_acl_rule" "nacl_rule" {
#   count = 2
#   network_acl_id = aws_network_acl.nacl.id
#   egress = false
#   rule_number = count.index
#   protocol = "6"
#   rule_action = "allow"
#   cidr_block = "
#   from_port = 0
#   to_port = 65535
# }

# resource "aws_network_acl_rule" "nacl_rule_egress" {
#   count = 2
#   network_acl_id = aws_network_acl.nacl.id
#   egress = true
#   rule_number = count.index
#   protocol = "6"
#   rule_action = "allow"
#   cidr_block = "
#   from_port = 0
#   to_port = 65535
# }