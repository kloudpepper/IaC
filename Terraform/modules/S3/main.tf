#########################
### Buckets S3 Module ###
#########################

locals {
  bucketName = ["export", "import", "request", "response"]
}

# Create S3 Buckets
resource "aws_s3_bucket" "bucket" {
  count = length(local.bucketName)
  bucket = "${var.environmentName}-file-${local.bucketName[count.index]}"
}

resource "aws_s3_bucket_acl" "acl" {
  count = length(local.bucketName)
  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "policy" {
  count = length(local.bucketName)
  bucket = aws_s3_bucket.bucket[count.index].id
  policy = <<EOF
  {
      "Version": "2012-10-17",
      "Id": "S3Policy",
      "Statement": [
          {
              "Sid": "AllowSSLRequestsOnly",
              "Effect": "Deny",
              "Principal": "*",
              "Action": "s3:*",
              "Resource": [
                  "arn:aws:s3:::${var.environmentName}-file-${local.bucketName[count.index]}",
                  "arn:aws:s3:::${var.environmentName}-file-${local.bucketName[count.index]}/*"
              ],
              "Condition": {
                  "Bool": {
                      "aws:SecureTransport": "false"
                  }
              }
          }
      ]
  }
  EOF
}

resource "aws_s3_bucket_versioning" "versioning" {
  count = length(local.bucketName)
  bucket = aws_s3_bucket.bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count = length(local.bucketName)
  bucket = aws_s3_bucket.bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      }
  }
} 

resource "aws_s3_bucket_public_access_block" "public_access_block" {
    count = length(local.bucketName)
    bucket = aws_s3_bucket.bucket[count.index].id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}