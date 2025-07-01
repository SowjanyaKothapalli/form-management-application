# Default configuration - do not commit to version control
# Create your own terraform.tfvars file for deployment

aws_region = "us-east-1"
app_name = "form-management-system"
environment = "production"

# This should match your RDS database URL 
# You can use environment variable TF_VAR_database_url instead
database_url = "postgresql://postgres:fullstackdb@database-1.c9eo6u4m6oll.us-east-2.rds.amazonaws.com:5432/postgres"

# Uncomment and update these if your RDS is in a VPC
# vpc_id = "vpc-056be3c13341441f0"
# subnet_ids = ["subnet-0df28202c9b089dc8", "subnet-026c4e5f3260830a7"]

# Set to true to create CloudFront distribution (recommended for production)
create_cloudfront = true
