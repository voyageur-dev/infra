data "aws_caller_identity" "current" {}

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

module "user_service" {
  source = "terraform-aws-modules/lambda/aws"
  depends_on = [module.cognito]

  function_name = "user-service-${var.environment}"
  handler       = "userservice.App::handleRequest"
  runtime       = "java17"

  create_package      = false
  s3_existing_package = {
    bucket = module.codebase_bucket.s3_bucket_id
    key    = "user-service-${var.environment}.jar"
  }

  publish = true

  allowed_triggers = {
    APIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*/*/*/*"
    }
  }

  attach_policies = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  ]

  environment_variables = {
    USER_POOL_ID = module.cognito.user_pool_id,
    CLIENT_ID    = module.cognito.client_id
  }

  timeout = 10
  memory_size = 256

  tags = {
    Name = "user-service"
    Environment = var.environment
  }
}

module "rb_service" {
  source = "terraform-aws-modules/lambda/aws"
  depends_on = [module.rb_questions_table, module.rb_bookmark_table]

  function_name = "rb-service-${var.environment}"
  handler       = "revisionbuddy.App::handleRequest"
  runtime       = "java17"

  create_package      = false
  s3_existing_package = {
    bucket = module.codebase_bucket.s3_bucket_id
    key    = "rb-service-${var.environment}.jar"
  }

  publish = true

  allowed_triggers = {
    APIGateway = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*/*/*/*"
    }
  }

  attach_policies = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  environment_variables = {
    QUESTIONS_TABLE_NAME = module.rb_questions_table.dynamodb_table_id,
    BOOKMARKS_TABLE_NAME = module.rb_bookmark_table.dynamodb_table_id
    EXAM_IDS = "aws-clf-c02,aws-dea-c01,aws-saa-c03,aws-sap-c02,aws-dva-c02"
  }

  timeout = 10
  memory_size = 256

  tags = {
    Name = "rb-service"
    Environment = var.environment
  }
}

module "rb_bookmark_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "rb-bookmarks-${var.environment}"
  hash_key = "user_id"
  range_key = "exam_question_key"

  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "exam_question_key"
      type = "S"
    }
  ]

  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  tags = {
    Environment = var.environment
  }
}

module "rb_questions_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "rb-questions-${var.environment}"
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

module "rb_question_images_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "rb-question-images-${var.environment}"
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
  depends_on = [module.user_service, module.rb_service]

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

  authorizers = {
    cognito = {
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      name             = "cognito"
      jwt_configuration = {
        audience         = [module.cognito.client_id]
        issuer           = "https://${module.cognito.endpoint}"
      }
    }
  }

  routes = {
    # user-service
    "POST /users" = {
      integration = {
        uri                    = module.user_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },
    "POST /users/code" = {
      integration = {
        uri                    = module.user_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },
    "POST /users/resend" = {
      integration = {
        uri                    = module.user_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },
    "POST /users/signIn" = {
      integration = {
        uri                    = module.user_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },

    # rb-service
    "GET /rb/questions" = {
      authorizer_key = "cognito"
      authorization_type = "JWT"

      integration = {
        uri                    = module.rb_service.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    },
    "GET /rb/metadata" = {
      authorizer_key = "cognito"
      authorization_type = "JWT"

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