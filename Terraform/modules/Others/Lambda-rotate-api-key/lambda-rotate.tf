data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./files/lambda_function.py"
  output_path = "./files/lambda_function.zip"
}

# Role to rotate the API Key
resource "aws_iam_role" "rotate_api_key_role" {
  name = "lambda_rotate_api_key_role"
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
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  tags = {
    "ib:resource:name" = "lambda_rotate_api_key_role",
    "Name"             = "lambda_rotate_api_key_role"
  }
}

# Policy to assume the role
resource "aws_iam_role_policy" "assume_role_policy" {
  name = "lambda_assume_role_policy"
  role = aws_iam_role.rotate_api_key_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:TagSession",
          "sts:AssumeRole"
        ],
        Resource = [
          "arn:aws:iam::909626174653:role/dev-rotate-api-key-role",
          "arn:aws:iam::783393171609:role/pre-rotate-api-key-role",
          "arn:aws:iam::123343909517:role/prod-rotate-api-key-role"
        ]
        Effect = "Allow"
        Sid    = "AllowAssumeRole"
      },
    ]
  })
}

# Policy to update the CloudFront header
resource "aws_iam_role_policy" "cloudfront_policy" {
  name = "lambda_cloudfront_policy"
  role = aws_iam_role.rotate_api_key_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudfront:UpdateDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:GetDistribution"
        ],
        Resource = [
          "arn:aws:cloudfront::130624267754:distribution/E3T3KJE4GHA3TF/*",
          "arn:aws:cloudfront::130624267754:distribution/E3T3KJE4GHA3TF",
        ]
        Effect = "Allow"
        Sid    = "UpdateHeaderCloudfront"
      },
    ]
  })
}

# Lambda function to rotate the API Key
resource "aws_lambda_function" "rotate_api_key" {
  function_name    = "lambda_rotate_api_key"
  description      = "Lambda to rotate API Key - CloudFront and API Gateway"
  role             = aws_iam_role.rotate_api_key_role.arn
  runtime          = "python3.12"
  timeout          = 30
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = merge(var.tags, {
    "ib:resource:name" = "lambda_rotate_api_key",
    "Name"             = "lambda_rotate_api_key"
  })
}

# EventBridge Rules to trigger the Lambda function
# INT Environment
resource "aws_cloudwatch_event_rule" "dev_rotate_api_key_rule" {
  name                = "dev_lambda_rotate_api_key_rule"
  description         = "Rule to rotate API key Dev Environment"
  schedule_expression = "cron(0 1 1 */3 ? *)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "dev_rotate_api_key_target" {
  target_id = "dev_rotate_api_key_target"
  rule      = aws_cloudwatch_event_rule.dev_rotate_api_key_rule.name
  arn       = aws_lambda_function.rotate_api_key.arn
  input = jsonencode({
    "API_GATEWAY_ROLE_ARN" : "arn:aws:iam::183625274653:role/dev-rotate-api-key-role",
    "DISTRIBUTION_ID" : "G3T4KJE4GHA3TF",
    "ORIGIN_ID" : "apigateway_main",
    "USAGE_PLAN_ID" : "h5jo9t",
    "API_KEY_NAME" : "dev-key"
  })
}

resource "aws_lambda_permission" "dev_rotate_api_key_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_api_key.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dev_rotate_api_key_rule.arn
}


# PRE Environment
resource "aws_cloudwatch_event_rule" "pre_rotate_api_key_rule" {
  name                = "pre_lambda_rotate_api_key_rule"
  description         = "Rule to rotate API key Pre Environment"
  schedule_expression = "cron(0 2 1 */3 ? *)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "pre_rotate_api_key_target" {
  target_id = "pre_rotate_api_key_target"
  rule      = aws_cloudwatch_event_rule.pre_rotate_api_key_rule.name
  arn       = aws_lambda_function.rotate_api_key.arn
  input = jsonencode({
    "API_GATEWAY_ROLE_ARN" : "arn:aws:iam::942396771601:role/pre-rotate-api-key-role",
    "DISTRIBUTION_ID" : "A3T3KGE4GJA3TD",
    "ORIGIN_ID" : "apigateway_main",
    "USAGE_PLAN_ID" : "fhex4t",
    "API_KEY_NAME" : "pre-key"
  })
}

resource "aws_lambda_permission" "pre_rotate_api_key_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_api_key.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pre_rotate_api_key_rule.arn
}


# PROD Environment
resource "aws_cloudwatch_event_rule" "prod_rotate_api_key_rule" {
  name                = "prod_lambda_rotate_api_key_rule"
  description         = "Rule to rotate API key Prod Environment"
  schedule_expression = "cron(0 3 1 */3 ? *)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "prod_rotate_api_key_target" {
  target_id = "prod_rotate_api_key_target"
  rule      = aws_cloudwatch_event_rule.prod_rotate_api_key_rule.name
  arn       = aws_lambda_function.rotate_api_key.arn
  input = jsonencode({
    "API_GATEWAY_ROLE_ARN" : "arn:aws:iam::632373020511:role/prod-rotate-api-key-role",
    "DISTRIBUTION_ID" : "G3F3KJD4GHA5TC",
    "ORIGIN_ID" : "apigateway_main",
    "USAGE_PLAN_ID" : "xmbg3h",
    "API_KEY_NAME" : "prod-key"
  })
}

resource "aws_lambda_permission" "prod_rotate_api_key_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_api_key.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.prod_rotate_api_key_rule.arn
}