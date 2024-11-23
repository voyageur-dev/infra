module "cognito" {
  source             = "../../modules/cognito"
  environment        = var.environment
}