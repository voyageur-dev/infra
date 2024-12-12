variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment name (int / prod)"
  type        = string
}

variable "registry" {
  description = "The registry for the ECR repository"
  type        = string
}