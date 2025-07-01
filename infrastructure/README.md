# Infrastructure Deployment

This directory contains Terraform configurations for deploying the Form Management System to AWS with:
- S3 static website hosting for the frontend
- Lambda Function for the backend API
- API Gateway to expose the Lambda function
- IAM roles and permissions

## Prerequisites

1. [AWS CLI](https://aws.amazon.com/cli/) installed and configured with appropriate credentials
2. [Terraform](https://www.terraform.io/downloads.html) v1.2.0 or later
3. [Python](https://www.python.org/downloads/) 3.8 or later
4. [Node.js](https://nodejs.org/) and npm

## Configuration

1. Create a `terraform.tfvars` file based on `terraform.tfvars.example`:

```
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` to set your desired values, especially the database URL.

## Deployment

### Option 1: Automated Deployment

Run the deployment script:

```
./deploy.sh
```

This script will:
1. Package the backend into a Lambda deployment zip with aws-wsgi
2. Build the frontend
3. Deploy the infrastructure with Terraform
4. Upload the frontend to S3

Note: Your backend will use `requirements-lambda.txt` if available, which includes the `aws-wsgi` package.

### Option 2: Manual Deployment

1. Package the backend:

```
cd ../backend
# Install aws-wsgi package
pip install aws-wsgi

# Create the deployment package
zip -r ../backend_lambda.zip src/ lambda_handler.py requirements.txt .env
cd temp_venv/lib/python*/site-packages
zip -r ../backend_lambda.zip . -x "*.pyc" "pip/*" "setuptools/*" "__pycache__/*" "*.dist-info/*"
cd ../
```

2. Build the frontend:

```
cd ../frontend
npm install
npm run build
cd ../infrastructure
```

3. Deploy the infrastructure:

```
cd ../infrastructure
terraform init
terraform apply
```

4. Upload the frontend:

```
cd ../
aws s3 sync frontend/dist/ s3://$(terraform -chdir=infrastructure output -raw frontend_bucket_name)/ --delete
```

## Post-Deployment

After deployment, update your frontend API configuration to point to the new API Gateway endpoint:

```javascript
// In your frontend API configuration
const API_URL = 'https://[API_GATEWAY_URL]';
```

You can find the API Gateway URL in the Terraform outputs.

## Clean Up

To destroy all resources created:

```
cd infrastructure
terraform destroy
```

## Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   S3 Bucket  │     │ API Gateway  │     │    Lambda    │
│   (Static    │────>│  (HTTP API)  │────>│   Function   │
│   Website)   │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
                                          ┌──────────────┐
                                          │  PostgreSQL  │
                                          │  Database    │
                                          │ (RDS)        │
                                          └──────────────┘
```
