output "LambdaSecurityGroup_id" {
    description = "Lambda Security Group ID"
    value = aws_security_group.LambdaSecurityGroup.id
}

output "SFTPSecurityGroup_id" {
    description = "SFTP Security Group ID"
    value = aws_security_group.SFTPSecurityGroup.id
}

output "ALBSecurityGroup_id" {
    description = "ALB Security Group ID"
    value = aws_security_group.ALBSecurityGroup.id
}

output "ECSSecurityGroup_id" {
    description = "ECS Security Group ID"
    value = aws_security_group.ECSSecurityGroup.id
}

output "MQSecurityGroup_id" {
    description = "MQ Security Group ID"
    value = aws_security_group.MQSecurityGroup.id
}

output "RDSSecurityGroup_id" {
    description = "RDS Security Group ID"
    value = aws_security_group.RDSSecurityGroup.id
}

output "EFSSecurityGroup_id" {
    description = "EFS Security Group ID"
    value = aws_security_group.EFSSecurityGroup.id
}

output "VPCEnpointSecurityGroup_id" {
    description = "VPC Enpoints Security Group ID"
    value = aws_security_group.VPCEnpointSecurityGroup.id
}