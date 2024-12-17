resource "aws_apigatewayv2_route" "routes" {
  for_each = var.routes

  api_id             = var.api_gateway_id
  route_key          = "${each.value.method} ${each.value.path}"
  target             = "integrations/${each.value.target}"
}