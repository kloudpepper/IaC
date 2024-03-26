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

resource "aws_iam_role" "SFTPUserRole_AS400" {
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
resource "aws_transfer_user" "AS400" {
  server_id      = aws_transfer_server.SFTPServer.id
  user_name      = "sftp_${var.environmentName}"
  role           = aws_iam_role.SFTPUserRole_AS400.arn
  home_directory = "/${var.environmentName}-file-export"
  tags = {
    Name = "AS400"
  }
}

resource "aws_transfer_ssh_key" "SSH_AS400" {
  server_id = aws_transfer_server.SFTPServer.id
  user_name = aws_transfer_user.AS400.user_name
  body      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV0s0dNp/6rsHxImenZfTINpn9qwqKLEtG8jchb6waBw32DmqsZpSfMNpPJoCsEVyZ85siYz/qbVYahXOaOfrVwOLDgGNMXSIkKzKrzVfhqJFYV7T+yj4xhqfNQBPhwosrKNAboe7CbwszGyYq6+rr8O1Kp2bsxcFn3ZPfapb0ZaHgJN2GYM7JrGFjmAtRt5eZWm6nQT96n+eOjFowfLEYFBEQqnhjIggF5clYGatJMUsEes3ld5glFhQJFFcpF01FyDTnZkT1S3XnjLpIxN5OdGqB7X1+1NgDhdAQEb2Fn03pxsCOW4X6sWQD7nN7JAdVxQd7GrxykblyV+VMKesrtITnu/gzk2KMjo7lebEMFQd84l43qdrhk2/m7+sNBiXzPff1ZH/8Q09P9UxeLAW80HbyuiQcyDG0emXMk3OL4tbspWsvfy09a1Sne108NsPauk1jr9zxJkvEFyY6KH3VneQsj1fMqSeut3TSv0Noh3yHaH3n+dd2dezr3AZLopU="
}
###
