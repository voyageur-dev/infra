resource "aws_lambda_function" "function" {
  image_uri       = "public.ecr.aws/w3e5l9o0/user-service-int:latest"
  function_name   = "${var.service_name}-${var.environment}"
  role = var.role_arn
  package_type    = "Image"

  timeout = 180

  tags = {
    Name  = var.service_name
    Environment = var.environment
  }
}