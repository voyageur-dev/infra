module "cognito" {
  source             = "../../modules/cognito"
  environment        = var.environment
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  environment = var.environment
  auto_deploy = true
}

module "user-service" {
  source = "../../modules/functions"
  environment = var.environment
  service_name = "user-service"
  role_arn = module.user-service-role.role_arn
  environment_variables = var.user_service_environment_variables
}

module "user-service-role" {
  source = "../../modules/role"
  environment = var.environment
  service_name = "user-service"
}

module "user-service-integration" {
  source = "../../modules/integration"
  api_gateway_id = module.api-gateway.api_gateway_id
  integration_uri = module.user-service.invoke_arn
}

module "route" {
  source = "../../modules/route"
  api_gateway_id = module.api-gateway.api_gateway_id

  routes = {
    "userservice.getUser" = {
      target = module.user-service-integration.integration_id
      path = "/users/{username}"
      method = "GET"
    },
    "userservice.createUser" = {
      target = module.user-service-integration.integration_id
      path = "/users"
      method = "POST"
    },
    "userservice.signIn" = {
      target = module.user-service-integration.integration_id
      path = "/users/signIn"
      method = "POST"
    }
  }
}

module "subscriptions_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "subscriptions-table-${var.environment}"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

  tags = {
    Name = "subscription-service"
    Environment = var.environment
  }
}