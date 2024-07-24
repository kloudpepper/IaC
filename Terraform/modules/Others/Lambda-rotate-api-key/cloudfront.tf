resource "aws_cloudfront_distribution" "cloudfront_api" {
  enabled             = true
  comment             = "${local.environment_prefix}-${local.cf_api_name}-cf"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  dynamic "origin" {
    for_each = local.cf_api_origins

    content {
      domain_name = origin.value.domain_origin
      origin_id   = origin.value.origin_id

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
  }

  lifecycle {
    ignore_changes = [
      origin,
    ]
  }

  default_cache_behavior {
    target_origin_id           = local.cf_api_origins[0].origin_id
    allowed_methods            = local.cf_api_origins[0].allowed_methods
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    min_ttl                    = local.cf_api_origins[0].min_ttl
    default_ttl                = local.cf_api_origins[0].default_ttl
    max_ttl                    = local.cf_api_origins[0].max_ttl
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cloudfront_api_headers.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.cf_api_origins

    content {
      target_origin_id           = ordered_cache_behavior.value.origin_id
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "redirect-to-https"
      path_pattern               = ordered_cache_behavior.value.path_pattern
      compress                   = true
      cache_policy_id            = local.cf_api_cache_policy_id
      origin_request_policy_id   = local.cf_api_request_policy_id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.cloudfront_api_headers.id
      min_ttl                    = ordered_cache_behavior.value.min_ttl
      default_ttl                = ordered_cache_behavior.value.default_ttl
      max_ttl                    = ordered_cache_behavior.value.max_ttl
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, {
    "ib:resource:name" = local.cf_api_name,
    "Name"             = local.cf_api_name,
    "alias"            = "${local.environment_prefix}-${local.cf_api_name}-cf"
  })
}

resource "aws_cloudfront_response_headers_policy" "cloudfront_api_headers" {
  name = "${local.environment_prefix}-${local.cf_api_name}-header-policy"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_security_policy {
      content_security_policy = "upgrade-insecure-requests"
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = true
      value    = "no-cache='Set-Cookie'"
    }
  }
}