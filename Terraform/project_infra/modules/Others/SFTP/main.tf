###################
### SFTP Module ###
###################

### Roles ###
resource "aws_iam_role" "SFTPCloudWatchLogsRole" {
  name                = "SFTPCloudWatchRole-${var.environmentName}"
  assume_role_policy  = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "transfer.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess"]
  path                = "/"
}

resource "aws_iam_role" "SFTPUserRole_AS4001" {
  name                = "SFTPUserRole_AS400-${var.environmentName}"
  assume_role_policy  = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "transfer.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  path                = "/"
}

### Server ###
resource "aws_transfer_server" "SFTPServer" {
  endpoint_type = "VPC"
  endpoint_details {
    subnet_ids         = [var.PrivateSubnet1_id, var.PrivateSubnet2_id]
    vpc_id             = var.vpc_id
    security_group_ids = [var.SFTPSecurityGroup_id]
  }
  protocols              = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.SFTPCloudWatchLogsRole.arn
  security_policy_name   = "TransferSecurityPolicy-FIPS-2020-06"
  tags = {
    Name = "SFTP-${var.environmentName}"
  }
}

### Users ###
# User AS400"
resource "aws_transfer_user" "AS4001" {
  server_id      = aws_transfer_server.SFTPServer.id
  user_name      = "sftp_${var.environmentName}"
  role           = aws_iam_role.SFTPUserRole_AS4001.arn
  home_directory = "/${var.environmentName}-file-export"
  tags = {
    Name = "AS400"
  }
}

resource "aws_transfer_ssh_key" "SSH_AS4001" {
  server_id = aws_transfer_server.SFTPServer.id
  user_name = aws_transfer_user.AS4001.user_name
  body      = ""
}
###
