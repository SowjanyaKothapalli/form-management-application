#!/bin/bash

# Build and deploy script for Form Management System

set -e  # Exit on error

echo "==========================================="
echo "Form Management System Deployment"
echo "==========================================="
export AWS_PROFILE=default
# Directory setup
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR/.."
BASE_DIR=$(pwd)
BACKEND_DIR="$BASE_DIR/backend"
FRONTEND_DIR="$BASE_DIR/frontend"
INFRA_DIR="$BASE_DIR/infrastructure"
LAMBDA_ZIP="$BASE_DIR/backend_lambda.zip"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Current working directory: $(pwd)${NC}"

# Check dependencies
echo "Checking dependencies..."
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}npm is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Python3 is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v pip >/dev/null 2>&1 || { echo -e "${RED}pip is required but not installed. Aborting.${NC}" >&2; exit 1; }

# 1. Prepare backend Lambda package
echo -e "${GREEN}Preparing backend Lambda package...${NC}"
cd "$BACKEND_DIR"

# Create virtualenv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt
pip install python-dotenv aws-wsgi

# Create deployment package
echo "Creating Lambda deployment package..."
cd "$BACKEND_DIR"
zip -r "$LAMBDA_ZIP" src/ lambda_handler.py requirements.txt .env
cd venv/lib/python*/site-packages
zip -r "$LAMBDA_ZIP" . -x "*.pyc" "*.dist-info/*" "pip/*" "setuptools/*" "wheel/*"

echo -e "${GREEN}Backend package created at: $LAMBDA_ZIP${NC}"

# 2. Build frontend
echo -e "${GREEN}Building frontend...${NC}"
cd "$FRONTEND_DIR"
npm install
npm run build

echo -e "${GREEN}Frontend build completed${NC}"

# 3. Run Terraform
echo -e "${GREEN}Deploying infrastructure with Terraform...${NC}"
cd "$INFRA_DIR"

if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Using example file...${NC}"
    cp terraform.tfvars.example terraform.tfvars
fi

# Initialize and apply Terraform configuration
terraform init
terraform validate
terraform plan -out=tfplan
echo -e "${YELLOW}Review the plan above. Do you want to apply these changes? (y/N)${NC}"
read -r confirmation
if [[ $confirmation =~ ^[Yy]$ ]]; then
    terraform apply tfplan
    echo -e "${GREEN}Infrastructure deployment completed!${NC}"
else
    echo -e "${YELLOW}Deployment canceled.${NC}"
    exit 0
fi

# 4. Run post-deployment steps
echo -e "${GREEN}Running post-deployment steps...${NC}"
"$INFRA_DIR/post_deploy.sh"

# 5. Display outputs
echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${YELLOW}For more detailed instructions, run: terraform output deployment_instructions${NC}"

echo -e "${YELLOW}Important: Make sure to update your frontend API URL configuration to point to the new API Gateway endpoint${NC}"
