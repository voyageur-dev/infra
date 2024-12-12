resource "aws_ecrpublic_repository" "public_repositories" {
  repository_name = "${var.service_name}-${var.environment}"

  tags = {
    Name  = var.service_name
    env   = var.environment
  }
}