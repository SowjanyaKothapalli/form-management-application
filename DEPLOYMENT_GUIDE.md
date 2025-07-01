# Form Management System - Deployment Guide

## Quick Start

To complete the deployment of your Form Management System, follow these steps:

1. **Ensure AWS Credentials**:
   ```bash
   aws configure --profile devtest
   ```
   Enter your AWS credentials with permissions to create Lambda, API Gateway, S3, CloudFront, and IAM resources.

2. **Fix CORS Configuration**:
   The API Gateway CORS configuration has been updated to properly handle the S3 website endpoint format.

3. **Run Deployment**:
   ```bash
   cd /home/ashok/Downloads/form-management-system/infrastructure
   ./restart_deploy.sh
   ```
   This script will:
   - Clean up any partially created resources
   - Deploy all infrastructure components
   - Update frontend configuration with API endpoint
   - Upload files to S3
   - Set up CloudFront (if enabled)

## Deployment Status

After running the script, you'll see the following resources created:
- S3 bucket for hosting frontend files
- Lambda function running the backend API
- API Gateway to expose the Lambda function
- CloudFront distribution for CDN (if enabled)

## Access Your Application

Your application will be available at:
- S3 Website: http://<bucket-name>.s3-website-<region>.amazonaws.com
- CloudFront (if enabled): https://<distribution-id>.cloudfront.net

## Troubleshooting

If you encounter issues:

1. **Check AWS Credentials**:
   Ensure your AWS credentials have the necessary permissions.

2. **CloudWatch Logs**:
   Check Lambda function logs in CloudWatch for backend errors.

3. **CORS Issues**:
   If you see CORS errors in the browser console, verify the API Gateway configuration.

4. **Database Connection**:
   Verify the PostgreSQL connection string in terraform.tfvars.

## Making Changes

If you need to make changes after deployment:
1. Update the code or configuration
2. Run `./deploy.sh` again to apply changes

## Resources

Detailed documentation can be found in:
- infrastructure/DEPLOYMENT.md - Full deployment documentation
- backend/LAMBDA_DEPLOYMENT.md - Backend Lambda information

Remember to secure your production environment appropriately by restricting access to resources and using proper authentication mechanisms.
