# Deploying the Form Management System

This document provides step-by-step instructions to deploy the Form Management System to AWS using Terraform.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (version 1.0+)
- Node.js and npm installed (for frontend build)
- Python 3.9+ installed (for backend)
- An existing PostgreSQL RDS instance

## Deployment Steps

### 1. Configure Terraform Variables

Edit `infrastructure/terraform.tfvars` to set your deployment configuration:

```
aws_region = "us-east-2"  # Match your RDS region
app_name = "form-management-system"
environment = "dev"
database_url = "postgresql://username:password@your-rds-instance:5432/dbname"
create_cloudfront = true  # Set to true to create CloudFront distribution
```

### 2. Run the Deployment Script

From the project root directory, run:

```bash
cd infrastructure
./deploy.sh
```

This script will:
- Build the backend Lambda package
- Build the frontend React application
- Deploy infrastructure resources with Terraform
- Update the frontend configuration with the deployed API Gateway URL
- Upload frontend files to S3
- Invalidate CloudFront cache (if CloudFront is enabled)

### 3. Manual Deployment (Alternative)

If you prefer to deploy manually or if the script fails:

#### Backend Deployment:

```bash
# Create Lambda package
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install python-dotenv aws-wsgi

# Create ZIP file
cd ..
zip -r backend_lambda.zip backend/src/ backend/lambda_handler.py backend/requirements.txt backend/.env
cd backend/venv/lib/python*/site-packages
zip -r ../../../../backend_lambda.zip . -x "*.pyc" "*.dist-info/*" "pip/*" "setuptools/*" "wheel/*"
```

#### Frontend Deployment:

```bash
# Build frontend
cd frontend
npm install
npm run build

# After Terraform deployment, update config.js with API Gateway URL
API_URL=$(cd ../infrastructure && terraform output -raw api_gateway_url)
# Update API_URL in src/config.js and rebuild

# Upload to S3
BUCKET=$(cd ../infrastructure && terraform output -raw frontend_bucket_name)
aws s3 sync dist/ s3://$BUCKET/
```

#### Terraform Deployment:

```bash
cd infrastructure
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# Run post-deployment steps
./post_deploy.sh
```

### 4. Verify Deployment

After deployment completes:

1. Access your frontend through either:
   - S3 website URL: http://<bucket-name>.s3-website-<region>.amazonaws.com
   - CloudFront URL: https://<distribution-id>.cloudfront.net

2. Test API functionality by submitting a form

3. Check CloudWatch logs for any backend errors

## Troubleshooting

### API Gateway CORS Issues

If you encounter CORS errors:

1. Ensure the API Gateway has proper CORS configuration
2. Check that the frontend is calling the correct API endpoint
3. Verify that the S3 website endpoint format is correct in the API Gateway CORS configuration

### CloudFront Issues

If CloudFront is not serving the site correctly:

1. Wait a few minutes for the distribution to fully deploy
2. Create a cache invalidation: `aws cloudfront create-invalidation --distribution-id <dist-id> --paths "/*"`

### Database Connection Issues

If the backend can't connect to the database:

1. Verify the database URL in `terraform.tfvars`
2. Ensure the RDS security group allows connections from Lambda
3. Check CloudWatch logs for specific connection errors

## Clean Up

To remove all deployed resources:

```bash
cd infrastructure
terraform destroy
```

This will delete all AWS resources created by this deployment except for your RDS database.
