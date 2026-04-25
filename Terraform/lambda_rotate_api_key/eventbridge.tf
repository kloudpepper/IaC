############################
### EventBridge Schedule ###
############################

# EventBridge Schedule to trigger the Lambda function
resource "aws_scheduler_schedule" "rotate_api_key_schedule" {
  name                         = "kloudpepper-rotate_api_key_schedule"
  description                  = "A scheduler to rotate API key on CloudFront and API Gateway"
  state                        = "ENABLED"
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 0 1 */1 ? *)"

  target {
    arn      = aws_lambda_function.rotate_api_key.arn
    role_arn = aws_iam_role.eventbridge_role.arn
    input = jsonencode({
      "DISTRIBUTION_ID" : aws_cloudfront_distribution.example.id,
      "ORIGIN_ID" : tolist(aws_cloudfront_distribution.example.origin)[0].origin_id,
      "USAGE_PLAN_ID" : aws_api_gateway_usage_plan.usage_plan.id,
      "API_KEY_NAME" : "kloudpepper-api-key"
    })
    retry_policy {
      maximum_event_age_in_seconds = 60
      maximum_retry_attempts       = 1
    }
  }
}

# - Role for EventBridge Scheduler
resource "aws_iam_role" "eventbridge_role" {
  name = "kloudpepper-eventbridge_role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

# - Policy to invoke Lambda function
resource "aws_iam_policy" "lambda_eventbridge_policy" {
  name = "kloudpepper-lambda_eventbridge_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          aws_lambda_function.rotate_api_key.arn
        ],
        "Sid" : "LambdaPermission"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "eventbridge_lambda_attachment" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = aws_iam_policy.lambda_eventbridge_policy.arn

  lifecycle {
    create_before_destroy = true
  }
}