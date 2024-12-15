variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment name (int / prod)"
  type        = string
  default     = "int"
}

variable "user_service_environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {
    USER_POOL_ID = "us-east-1_BL4RLmsOa"
  }
}