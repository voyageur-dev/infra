resource "aws_ecrpublic_repository" "public_repository" {
  repository_name = "${var.service_name}-${var.environment}"

  tags = {
    Name  = var.service_name
    Environment = var.environment
  }
}