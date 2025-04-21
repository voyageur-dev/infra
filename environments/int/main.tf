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

module "rb_service" {
  source = "terraform-aws-modules/lambda/aws"
  depends_on = [module.rb_exam_questions_table]

  function_name = "rb-service-${var.environment}"
  handler       = "revisionbuddy.App::handleRequest"
  runtime       = "java17"

  create_package      = false
  s3_existing_package = {
    bucket = module.codebase_bucket.s3_bucket_id
    key    = "rb-service-${var.environment}.jar"
  }

  attach_policies = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]

  environment_variables = {
    QUESTIONS_TABLE_NAME = module.rb_exam_questions_table.dynamodb_table_id,
  }

  timeout = 10
  memory_size = 256

  tags = {
    Name = "rb-service"
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
    Environment = var.environment
  }
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  depends_on = [module.rb_service]

  name          = "api-gateway-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Disable creation of the domain name and API mapping
  create_domain_name = false

  # Disable creation of Route53 alias record(s) for the custom domain
  create_domain_records = false

  # Disable creation of the ACM certificate for the custom domain
  create_certificate = false

  routes = {
    "GET /rb/questions" = {
      integration = {
        uri                    = module.rb_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },

    "GET /rb/{examId}/metadata" = {
      integration = {
        uri                    = module.rb_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}