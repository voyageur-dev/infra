module "repositories" {
  source = "../../modules/repositories"
  environment = var.environment
  service_name = "user-service"
}