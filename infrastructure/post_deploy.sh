#!/bin/bash

# Post-deployment script for Form Management System
# This script:
# 1. Updates the frontend config.js with the API Gateway URL
# 2. Rebuilds the frontend with updated configuration
# 3. Uploads the built frontend to S3
# 4. Invalidates CloudFront cache (if applicable)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directory setup
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR/.."
BASE_DIR=$(pwd)
FRONTEND_DIR="$BASE_DIR/frontend"
INFRA_DIR="$BASE_DIR/infrastructure"
CONFIG_FILE="$FRONTEND_DIR/src/config.js"

echo -e "${GREEN}Starting post-deployment steps...${NC}"

# 1. Get the API Gateway URL from Terraform output
cd "$INFRA_DIR"
API_GATEWAY_URL=$(terraform output -raw api_gateway_url)
BUCKET_NAME=$(terraform output -raw frontend_bucket_name)
CLOUDFRONT_ENABLED=$(terraform output -json | grep -c "cloudfront_domain_name")

echo -e "${GREEN}API Gateway URL: ${API_GATEWAY_URL}${NC}"
echo -e "${GREEN}S3 Bucket Name: ${BUCKET_NAME}${NC}"

if [ -z "$API_GATEWAY_URL" ] || [ -z "$BUCKET_NAME" ]; then
    echo -e "${RED}Failed to get Terraform outputs. Make sure deployment was successful.${NC}"
    exit 1
fi

# 2. Update frontend config.js with API Gateway URL
echo -e "${GREEN}Updating frontend configuration...${NC}"
sed -i '' "s|https://REPLACE_WITH_API_GATEWAY_URL/api|${API_GATEWAY_URL}|g" "$CONFIG_FILE"

echo -e "${GREEN}Frontend configuration updated with API Gateway URL: ${API_GATEWAY_URL}${NC}"
echo -e "${YELLOW}Configuration file content:${NC}"
cat "$CONFIG_FILE"

# 3. Rebuild frontend with updated configuration
echo -e "${GREEN}Rebuilding frontend with updated configuration...${NC}"
cd "$FRONTEND_DIR"
npm ci
npm run build

# 4. Upload frontend to S3
echo -e "${GREEN}Uploading frontend to S3...${NC}"
aws s3 sync "$FRONTEND_DIR/dist/" "s3://$BUCKET_NAME/" --delete

echo -e "${GREEN}Frontend successfully uploaded to S3 bucket: ${BUCKET_NAME}${NC}"

# 5. Invalidate CloudFront cache if enabled
if [ "$CLOUDFRONT_ENABLED" -gt 0 ]; then
    CLOUDFRONT_ID=$(terraform -chdir="$INFRA_DIR" output -raw cloudfront_distribution_id 2>/dev/null || echo "")
    
    if [ ! -z "$CLOUDFRONT_ID" ]; then
        echo -e "${GREEN}Invalidating CloudFront cache for distribution: ${CLOUDFRONT_ID}${NC}"
        aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_ID" --paths "/*"
    else
        echo -e "${YELLOW}CloudFront enabled but distribution ID not found. Skipping invalidation.${NC}"
    fi
fi

# 6. Display access URLs
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Your application is now accessible at:${NC}"

# Get S3 website URL
S3_WEBSITE=$(terraform -chdir="$INFRA_DIR" output -raw frontend_website_endpoint)
echo -e "${GREEN}S3 Website: http://${S3_WEBSITE}${NC}"

# Get CloudFront URL if enabled
if [ "$CLOUDFRONT_ENABLED" -gt 0 ]; then
    CLOUDFRONT_URL=$(terraform -chdir="$INFRA_DIR" output -raw cloudfront_domain_name 2>/dev/null || echo "")
    if [ ! -z "$CLOUDFRONT_URL" ]; then
        echo -e "${GREEN}CloudFront: https://${CLOUDFRONT_URL}${NC}"
    fi
fi

echo -e "${GREEN}API Gateway: ${API_GATEWAY_URL}${NC}"
echo -e "${YELLOW}Note: It may take a few minutes for the CloudFront distribution to fully deploy.${NC}"
