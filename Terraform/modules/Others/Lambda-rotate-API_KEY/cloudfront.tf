#########################
### CloudFront Module ###
#########################

resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name = "${aws_api_gateway_rest_api.example.id}.execute-api.us-east-1.amazonaws.com"
    origin_id   = "api-gateway-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "x-api-key"
      value = ""
    }
  }

  lifecycle {
    ignore_changes = [
      origin,
    ]
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example CloudFront distribution with API Gateway"
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}