terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

#################################################
# S3 Bucket for Frontend Hosting
#################################################

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.app_name}-frontend"

  tags = {
    Name        = "${var.app_name}-frontend"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend" {
  depends_on = [
    aws_s3_bucket_ownership_controls.frontend,
    aws_s3_bucket_public_access_block.frontend,
  ]

  bucket = aws_s3_bucket.frontend.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

#################################################
# Lambda Function for Backend API
#################################################

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch logs policy attachment for Lambda
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy attachment for Lambda (if connecting to RDS in a VPC)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# RDS connection policy
resource "aws_iam_policy" "rds_access" {
  name        = "${var.app_name}-rds-access"
  description = "Allow Lambda to connect to RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:*",
          "rds-db:connect"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.rds_access.arn
}

# Lambda function for the backend API
resource "aws_lambda_function" "backend" {
  function_name = "${var.app_name}-backend"
  description   = "Backend API for Form Management System"
  
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_handler.handler"
  runtime       = "python3.12"
  
  filename      = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  
  timeout       = 30
  memory_size   = 512
  
  environment {
    variables = {
      DATABASE_URL = var.database_url
      FLASK_ENV    = var.environment
      PYTHONPATH   = "/var/task:/var/task/lib"
    }
  }

  # Uncomment and configure these if your RDS is in a VPC
  # vpc_config {
  #   subnet_ids         = var.subnet_ids
  #   security_group_ids = [aws_security_group.lambda.id]
  # }

  # Enable function URL for direct access (optional)
  # publish = true
}

# API Gateway for Lambda exposure
resource "aws_apigatewayv2_api" "backend_api" {
  name          = "${var.app_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [
      "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}",
      "https://${aws_s3_bucket_website_configuration.frontend.website_endpoint}",
      "http://localhost:5173",  # Local development
      "*"  # For testing - restrict in production
    ]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_stage" "backend_stage" {
  api_id      = aws_apigatewayv2_api.backend_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "backend_integration" {
  api_id                 = aws_apigatewayv2_api.backend_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "backend_route" {
  api_id    = aws_apigatewayv2_api.backend_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_integration.id}"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend_api.execution_arn}/*/*/{proxy+}"
}
