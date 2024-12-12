resource "aws_lambda_function" "function" {
  image_uri       = "public.ecr.aws/${var.ecr_alias}/${var.service_name}-${var.environment}:latest"
  function_name   = "${var.service_name}-${var.environment}"
  role = var.role_arn
  package_type    = "Image"

  timeout = 180

  tags = {
    Name  = var.service_name
    Environment = var.environment
  }
}