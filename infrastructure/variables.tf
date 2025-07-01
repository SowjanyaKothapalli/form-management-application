variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"  # Using the same region as your existing RDS
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "form-management-system"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_zip_path" {
  description = "Path to zip file containing Lambda function code"
  type        = string
  default     = "../backend_lambda.zip"
}

variable "database_url" {
  description = "PostgreSQL database connection string"
  type        = string
  sensitive   = true
  # This will be set via terraform.tfvars or environment variable TF_VAR_database_url
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Lambda function (needed if connecting to RDS in VPC)"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for the security group (needed if connecting to RDS in VPC)"
  type        = string
  default     = ""
}

variable "create_cloudfront" {
  description = "Whether to create a CloudFront distribution for the frontend"
  type        = bool
  default     = false
}
