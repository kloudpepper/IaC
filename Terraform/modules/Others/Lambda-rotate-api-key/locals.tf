locals {
  environment_prefix       = "${var.project}-${var.environment}"
  environment_prefix_short = "${var.project_short}-${var.environment}"

  ########################################
  ### Cloudfront distribution for backend
  ########################################

  cf_custom_header         = "Connect-From-CloudFront"
  domain_base              = "api.kloudpepper.com"
  cf_api_name              = "api-test"
  cf_api_domain            = "${local.cf_api_name}.${local.domain_base}"
  cf_api_cache_policy_id   = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  cf_api_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" //AllViewersExceptHostHeader

  cf_api_origins = [
    {
      path_pattern    = "/cloud/*"
      origin_id       = "apigateway_main"
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      domain_origin   = "apigw.kloudpepper.com"
      min_ttl         = 0
      default_ttl     = 0
      max_ttl         = 0
    }
  ]
}