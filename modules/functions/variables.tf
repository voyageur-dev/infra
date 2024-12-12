variable "service_name" {
  description = "The repository for which service"
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