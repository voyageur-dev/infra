
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = var.api_gateway_id
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.integration_uri
}