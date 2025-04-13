resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.integration_uri
  payload_format_version = "2.0"
}