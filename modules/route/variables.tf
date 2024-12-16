variable "routes" {
  type = map(object({
    target     = string
    method = string
    path   = string
  }))
  description = "Map of route configurations"
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}