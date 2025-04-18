module "cognito" {
  source             = "../../modules/cognito"
  environment        = var.environment
}

module "codebase_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "codebase-${var.environment}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  tags = {
    Environment = var.environment
  }
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
  environment_variables = {
    USER_POOL_ID = module.cognito.user_pool_id,
    CLIENT_ID    = module.cognito.client_id
  }
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
    "userservice.signUp" = {
      target = module.user-service-integration.integration_id
      path = "/users"
      method = "POST"
    },
    "userservice.confirmSignUp" = {
      target = module.user-service-integration.integration_id
      path = "/users/code"
      method = "POST"
    },
    "userservice.resendCode" = {
      target = module.user-service-integration.integration_id
      path = "/users/resend"
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
      type = "S"
    }
  ]

  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  tags = {
    Name = "subscription-service"
    Environment = var.environment
  }
}

module "rb_exam_questions_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "rb-exam-questions-${var.environment}"
  hash_key = "exam_id"
  range_key = "question_id"

  attributes = [
    {
      name = "exam_id"
      type = "S"
    },
    {
      name = "question_id"
      type = "N"
    }
  ]

  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  tags = {
    Name = "rb-service"
    Environment = var.environment
  }
}

module "rb_exam_question_images_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "rb-exam-question-images-${var.environment}"
  acl    = "private"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  tags = {
    Name = "rb-service"
    Environment = var.environment
  }
}