output "integration_id" {
  description = "API Gateway V2 integration identifier"
  value = aws_apigatewayv2_integration.lambda_integration.id
}