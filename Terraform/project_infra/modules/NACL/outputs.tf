output "public_nacl_id" {
  value = aws_network_acl.public_nacl.id
}

output "private_nacl_id" {
  value = aws_network_acl.private_nacl.id
}