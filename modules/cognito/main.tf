resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool-${var.environment}"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  auto_verified_attributes = ["email"]

  alias_attributes = ["email"]

  tags = {
    Environment = var.environment
  }
}
