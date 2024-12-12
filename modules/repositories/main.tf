resource "aws_ecr_repository" "repository" {
  name = "${var.service_name}-${var.environment}"

  tags = {
    Name  = var.service_name
    env   = var.environment
  }
}