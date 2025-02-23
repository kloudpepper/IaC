#####################
### Lambda Module ###
#####################

# A Lambda function will rotate the API Key on CloudFront and API Gateway. 
# It will be triggered by a CloudWatch event schedule to update the CloudFront header and API Gateway API Key.

data "archive_file" "kloudpepper_lambda_zip" {
  type        = "zip"
  source_file = "./function/lambda_function.py"
  output_path = "./function/lambda_function.zip"
}

# Role to Lambda function
resource "aws_iam_role" "rotate_api_key_role" {
  name = "kloudpepper_lambda_rotate_api_key_role"
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
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

# Policy to update the CloudFront header
resource "aws_iam_policy" "cloudfront_policy" {
  name = "kloudpepper_lambda_cloudfront_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "UpdateHeaderCloudfront",
      Effect = "Allow",
      Action = [
        "cloudfront:UpdateDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:GetDistribution"
      ],
      Resource = [
        "${aws_cloudfront_distribution.example.arn}/*",
        "${aws_cloudfront_distribution.example.arn}"
      ]
    }]
  })
}

# Policy to update the API KEY on API Gateway
resource "aws_iam_policy" "api_gateway_policy" {
  name = "kloudpepper_lambda_api_gateway_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "apigateway:DELETE",
        "apigateway:POST",
        "apigateway:GET"
      ],
      Resource = "*"
    }]
  })
}

# Attach the policies to the role
resource "aws_iam_role_policy_attachments_exclusive" "policy_attachments" {
  role_name = aws_iam_role.rotate_api_key_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.cloudfront_policy.arn,
    aws_iam_policy.api_gateway_policy.arn
  ]
}

# Lambda function to rotate the API KEY on CloudFront and API Gateway
resource "aws_lambda_function" "rotate_api_key" {
  function_name    = "kloudpepper_rotate_api_key"
  description      = "Lambda to rotate API Key on CloudFront and API Gateway"
  role             = aws_iam_role.rotate_api_key_role.arn
  runtime          = "python3.12"
  timeout          = 30
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.kloudpepper_lambda_zip.output_path
  source_code_hash = data.archive_file.kloudpepper_lambda_zip.output_base64sha256
}

# EventBridge Rules to trigger the Lambda function
resource "aws_cloudwatch_event_rule" "rotate_api_key_rule" {
  name                = "kloudpepper-rotate_api_key_rule"
  description         = "Rule to rotate API key on CloudFront and API Gateway"
  schedule_expression = "cron(0 0 1 */1 ? *)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "rotate_api_key_target" {
  target_id = "rotate_api_key_target"
  rule      = aws_cloudwatch_event_rule.rotate_api_key_rule.name
  arn       = aws_lambda_function.rotate_api_key.arn
  input = jsonencode({
    "DISTRIBUTION_ID" : aws_cloudfront_distribution.example.id,
    "ORIGIN_ID" : tolist(aws_cloudfront_distribution.example.origin)[0].origin_id,
    "USAGE_PLAN_ID" : aws_api_gateway_usage_plan.usage_plan.id,
    "API_KEY_NAME" : "kloudpepper-api-key"
  })
}

resource "aws_lambda_permission" "rotate_api_key_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_api_key.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rotate_api_key_rule.arn
}