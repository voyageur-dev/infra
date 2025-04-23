output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.id
}

output "endpoint" {
  description = "The endpoint of the Cognito User Pool"
  value = aws_cognito_user_pool.user_pool.endpoint
}

output "client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}