module "cognito" {
  source             = "../../modules/cognito"
  environment        = var.environment
}

module "user-service" {
  source = "../../modules/functions"
  environment = var.environment
  registry    = var.registry
  service_name = "user-service"
  role_arn = module.user-service-role.role_arn
}

module "user-service-role" {
  source = "../../modules/role"
  environment = var.environment
  service_name = "user-service"
}