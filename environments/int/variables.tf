variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment name (int / prod)"
  type        = string
}

variable "user_service_environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
}