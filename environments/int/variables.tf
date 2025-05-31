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

variable "access_token_amplify" {
  description = "Access token for amplify to auto deploy github repo"
  type        = string
}

variable "genai_api_key" {
  description = "genai api key"
  type        = string
  sensitive   = true
}