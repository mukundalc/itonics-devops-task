# API Gateway REST API
resource "aws_api_gateway_rest_api" "messages_api" {
  name        = "messages-api"
  description = "API Gateway for messages Lambda function"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# /messages resource
resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  parent_id   = aws_api_gateway_rest_api.messages_api.root_resource_id
  path_part   = "messages"
}

# /messages/{messageId} resource
resource "aws_api_gateway_resource" "message_id" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  parent_id   = aws_api_gateway_resource.messages.id
  path_part   = "{messageId}"
}

# GET method
resource "aws_api_gateway_method" "get_message" {
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  resource_id   = aws_api_gateway_resource.message_id.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda integration
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.messages_api.id
  resource_id             = aws_api_gateway_resource.message_id.id
  http_method             = aws_api_gateway_method.get_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.messages_api.invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "prod" {
  depends_on = [
    aws_api_gateway_integration.lambda
  ]
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
}

# prod stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  stage_name    = "prod"
}

# Lambda permission
resource "aws_lambda_permission" "api-gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.messages_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.messages_api.execution_arn}/*/*/*"
}

# Output the invoke URL
output "api_url" {
  description = "Base URL for API Gateway stage"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/messages/{messageId}"
}