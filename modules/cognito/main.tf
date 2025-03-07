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

  username_attributes      = ["email"]

  auto_verified_attributes = ["email"]

  tags = {
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH"
  ]

  generate_secret = false

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  enable_token_revocation = true
}