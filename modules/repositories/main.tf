resource "aws_ecr_repository" "public_repository" {
  name = "${var.service_name}-${var.environment}"

  tags = {
    Name  = var.service_name
    Environment = var.environment
  }
}