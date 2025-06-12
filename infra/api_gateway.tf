# Define the API Gateway REST API
resource "aws_api_gateway_rest_api" "vaultwarden_api" {
  name        = "vaultwarden-api"
  description = "API Gateway for Vaultwarden Lambda"
}

# Define the API Gateway Resource (Path)
resource "aws_api_gateway_resource" "vaultwarden_resource" {
  rest_api_id = aws_api_gateway_rest_api.vaultwarden_api.id
  parent_id   = aws_api_gateway_rest_api.vaultwarden_api.root_resource_id
  path_part   = "vaultwarden"
}

# Define the Method (GET, POST, etc.)
resource "aws_api_gateway_method" "vaultwarden_method" {
  rest_api_id   = aws_api_gateway_rest_api.vaultwarden_api.id
  resource_id   = aws_api_gateway_resource.vaultwarden_resource.id
  http_method   = "ANY"
  authorization = "NONE" # You can change this to "AWS_IAM" or "COGNITO_USER_POOLS" for auth
}

# Integrate the Method with the Lambda Function
resource "aws_api_gateway_integration" "vaultwarden_integration" {
  rest_api_id = aws_api_gateway_rest_api.vaultwarden_api.id
  resource_id = aws_api_gateway_resource.vaultwarden_resource.id
  http_method = aws_api_gateway_method.vaultwarden_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.vaultwarden_lambda.invoke_arn
}

# Deploy the API Gateway (Stage: prod)
resource "aws_api_gateway_deployment" "vaultwarden_deployment" {
  depends_on  = [aws_api_gateway_integration.vaultwarden_integration]
  rest_api_id = aws_api_gateway_rest_api.vaultwarden_api.id
  #stage_name  = "prod" #Argument is deprecated.
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.vaultwarden_api.id
  deployment_id = aws_api_gateway_deployment.vaultwarden_deployment.id
}


# Attach Permissions (Lambda Invocation)
resource "aws_lambda_permission" "vaultwarden_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vaultwarden_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Allow invocation from this specific API Gateway
  source_arn = "${aws_api_gateway_rest_api.vaultwarden_api.execution_arn}/*/*"
}
