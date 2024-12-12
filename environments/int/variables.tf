variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment name (int / prod)"
  type        = string
}

variable "ecr_alias" {
  description = "The alias for the ECR repository"
  type        = string
}