region = "us-east-1"
environment = "int"
user_service_environment_variables = {
  COGNITO_USER_POOL_ID = module.cognito.user_pool_id
}