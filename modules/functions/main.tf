data "aws_ecr_repository" "function_repository" {
  name = "${var.service_name}-${var.environment}"
}

resource "aws_lambda_function" "function" {
  image_uri       = "${data.aws_ecr_repository.function_repository.repository_url}:latest"
  function_name   = "${var.service_name}-${var.environment}"
  role = var.role_arn
  package_type    = "Image"

  timeout = 180

  environment {
    variables = var.environment_variables
  }

  tags = {
    Name  = var.service_name
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "execution_lambda_from_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
}