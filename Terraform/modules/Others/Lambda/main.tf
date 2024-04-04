#####################
### Lambda Module ###
#####################

### Roles ###
resource "aws_iam_role" "LambdaRoleExporter" {
  name               = "LambdaRoleExporter-${var.environmentName}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  path = "/"
}

resource "aws_iam_role" "LambdaRoleMonitoring" {
  name               = "LambdaRoleMonitoring-${var.environmentName}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  path = "/"
}

resource "aws_iam_role" "LambdaRoleWarmUp" {
  name               = "LambdaRoleWarmUp-${var.environmentName}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  path = "/"
}

resource "aws_lambda_function" "LambdaFunctionExporter" {
  function_name = "${var.environmentName}-Exporter"
  handler       = "lambda_function.lambda_handler"
  architectures = [
    "x86_64"
  ]
  s3_bucket   = "cf-templates-main"
  s3_key      = "Lambda/lambda-exporter.zip"
  memory_size = 128
  role        = aws_iam_role.LambdaRoleExporter.arn
  runtime     = "python3.10"
  timeout     = 90
  vpc_config {
    subnet_ids         = [var.PrivateSubnet1_id, var.PrivateSubnet2_id]
    security_group_ids = [var.LambdaSecurityGroup_id]
  }
  environment {
    variables = {
      REQUESTURL         = "https://${var.environmentName}.example.com/agents/itemCount"
      THRESHOLD          = "12"
      PROVISIONINGFACTOR = "1"
      RESOURCEID         = "service/${var.environmentName}-cluster/${var.environmentName}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "EventRuleExporter" {
  name                = "${var.environmentName}-rule"
  schedule_expression = "rate(1 minute)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "EventTargetExporter" {
  target_id = "EventTargetExporter"
  rule      = aws_cloudwatch_event_rule.EventRuleExporter.name
  arn       = aws_lambda_function.LambdaFunctionExporter.arn
}

resource "aws_lambda_permission" "EventRulePermissionExporter" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaFunctionExporter.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EventRuleExporter.arn
}