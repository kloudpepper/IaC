# A Lambda function to synchronise S3 buckets.
# The Lambda function will be triggered every 5 minutes.

data "archive_file" "s3_sync_lambda_zip" {
  type        = "zip"
  source_file = "./lambda_function.py"
  output_path = "./lambda_function.zip"
}

# Lambda role to sync buckets
resource "aws_iam_role" "s3_sync_role" {
  name = "${local.environment_prefix}_lambda_s3_sync_role"
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
    "ib:resource:name" = "${local.environment_prefix}_lambda_s3_sync_role",
    "Name"             = "${local.environment_prefix}_lambda_s3_sync_role"
  }
}

# Policy to allow the Lambda function to access the S3 buckets
resource "aws_iam_policy" "s3_sync_policy" {
  name = "${local.environment_prefix}_lambda_s3_sync_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:::kloudpepper-source",
          "arn:aws:s3:::kloudpepper-source/*",
          "arn:aws:s3:::kloudpepper-destination",
          "arn:aws:s3:::kloudpepper-destination/*"
        ],
        "Sid" : "AccessToCacheIngestorS3Bucket"
      }
    ]
  })

  tags = {
    "ib:resource:name" = "${local.environment_prefix}_lambda_s3_sync_policy",
    "Name"             = "${local.environment_prefix}_lambda_s3_sync_policy"
  }
}

# Lambda function to sync buckets
resource "aws_lambda_function" "s3_sync_lambda" {
  function_name    = "${local.environment_prefix}_lambda_s3_sync"
  description      = "Lambda to synchronise S3 buckets"
  role             = aws_iam_role.rotate_api_key_role.arn
  runtime          = "python3.12"
  timeout          = 300
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.s3_sync_lambda_zip.output_path
  source_code_hash = data.archive_file.s3_sync_lambda_zip.output_base64sha256
  environment {
    variables = {
      SRC_BUCKET = "kloudpepper-source"
      DST_BUCKET = "kloudpepper-destination"
    }
  }
  tags = merge(var.tags, {
    "ib:resource:name" = "${local.environment_prefix}_lambda_s3_sync",
    "Name"             = "${local.environment_prefix}_lambda_s3_sync"
  })
}

# EventBridge Rules to trigger the Lambda function
resource "aws_cloudwatch_event_rule" "s3_sync_rule" {
  name                = "${local.environment_prefix}_lambda_s3_sync_rule"
  description         = "Rule to execute the Lambda function to sync S3 buckets"
  schedule_expression = "rate(5 minutes)"
  state               = "ENABLED"
  tags = merge(var.tags, {
    "ib:resource:name" = "${local.environment_prefix}_lambda_s3_sync_rule",
    "Name"             = "${local.environment_prefix}_lambda_s3_sync_rule"
  })
}

resource "aws_cloudwatch_event_target" "s3_sync_target" {
  target_id = "s3_sync_target"
  rule      = aws_cloudwatch_event_rule.s3_sync_rule.name
  arn       = aws_lambda_function.s3_sync_lambda.arn
}

resource "aws_lambda_permission" "s3_sync_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_sync_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_sync_rule.arn
}