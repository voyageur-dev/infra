module "user_service_repository" {
  source = "../../modules/repositories"
  environment = var.environment
  service_name = "user-service"
}