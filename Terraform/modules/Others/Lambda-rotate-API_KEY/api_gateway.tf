##########################
### API Gateway Module ###
##########################

# Create a REST API
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API Gateway"
}

# Create a resource
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

# Create GET method
resource "aws_api_gateway_method" "example_method" {
  rest_api_id      = aws_api_gateway_rest_api.example.id
  resource_id      = aws_api_gateway_resource.example_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# Create a MOCK integration
resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Create a 200 status code response
resource "aws_api_gateway_integration_response" "example_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{\"message\": \"Success\"}"
  }
}

# Create a 200 status code method response
resource "aws_api_gateway_method_response" "example_method_response" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  status_code = "200"
}

# Create a deployment
resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [
    aws_api_gateway_integration.example_integration,
    aws_api_gateway_integration_response.example_integration_response
  ]
  rest_api_id = aws_api_gateway_rest_api.example.id
}

# Create DEV stage
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.example_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "dev"
}

# Create a usage plan
resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "api-key-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.example.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }

  lifecycle {
    ignore_changes = [
      id,
      name
    ]
  }
}