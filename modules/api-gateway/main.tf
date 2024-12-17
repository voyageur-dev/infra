resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-gateway-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = var.environment
  auto_deploy = var.auto_deploy
}
