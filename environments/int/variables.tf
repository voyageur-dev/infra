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
