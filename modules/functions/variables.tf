variable "service_name" {
  description = "The repository for which service"
  type        = string
}

variable "environment" {
  description = "The environment name (int / prod)"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the role to assume"
  type        = string
}