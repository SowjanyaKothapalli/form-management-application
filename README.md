![CI](https://github.com/SowjanyaKothapalli/form-management-application/actions/workflows/test.yml/badge.svg?branch=main)

![Deploy](https://github.com/SowjanyaKothapalli/form-management-application/actions/workflows/deploy.yml/badge.svg?branch=main)

---

## 📖 Project Overview

### 🧱 Technology Stack
- **Frontend**: React + Vite
- **Backend**: Flask + Python
- **Database**: Amazon RDS PostgreSQL
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Deployment**: AWS Lambda, API Gateway, S3, CloudFront

### ⚙ Architecture Decisions
- **Serverless architecture** for backend via AWS Lambda to reduce costs
- **Static site hosting** for frontend via S3 + CloudFront for performance
- **Terraform** for reproducible, version-controlled infrastructure

### ✨ Key Features
- Responsive form with validation
- Submit, view, edit, delete form entries
- Search and filter submissions
- Pagination, confirmation dialogs, and toasts

### 💸 Cost Optimization
- Free-tier AWS services (S3, CloudFront, Lambda, API Gateway, RDS t3.micro)
- Environment-based config for production/dev separation
- Reserved instances for predictable workloads
- Tagging and monitoring enabled for usage tracking

---

## 🛠 Setup Instructions

### 🖥️ Local Development
```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend
cd frontend
npm install
npm run dev
```

### 🗃️ Database Setup
- Configure PostgreSQL via Amazon RDS
- Use `schema.sql` to initialize tables (includes constraints and indices)
- Secure credentials using `.env` and AWS Secrets Manager

### 🔐 Environment Configuration
- `.env` in both `frontend/` and `backend/`
- Terraform reads from `terraform.tfvars`
- Example variables:
  ```bash
  API_URL=https://your-api-endpoint
  DB_URL=postgresql://user:pass@host:port/dbname
  AWS_REGION=us-east-2
  ```

---

## 🧪 Testing

### 🧪 How to Run Tests
```bash
# Backend
cd backend
pytest --cov=src

# Frontend
cd frontend
npm run test
```

### 📊 Test Coverage
- `pytest-cov` for Flask
- `vitest` or `jest` for React
- GitHub Actions uploads coverage to Codecov

### ✅ Strategy
- Unit tests for API endpoints
- Input validation tests
- Database interaction tests (mocked and real)
- Component and integration tests for frontend

---

## 🚀 Deployment

### 🧍 Manual Deployment
```bash
cd infrastructure
bash deploy.sh
```
This builds the backend Lambda, frontend, and applies Terraform infra changes.

### 🤖 CI/CD Pipeline
- `test.yml`: runs tests and lint on every push/pull request
- `deploy.yml`: auto-deploys frontend to S3 + CloudFront on `main` merges
- Backend and infra managed manually via `deploy.sh`

---

## ☁️ AWS Configuration

### 👤 IAM Setup
- IAM user for GitHub Actions: `github-actions-deployer`
- Permissions:
  - `s3:*` for frontend bucket
  - `cloudfront:CreateInvalidation`
  - `lambda:*`, `apigateway:*`, `rds:*` as needed for manual deploys

### 🧱 Resource Provisioning (via Terraform)
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### 📈 Monitoring & Logging
- **CloudWatch Logs** for Lambda and API Gateway
- **Terraform outputs** give CloudFront + API endpoints
- S3 versioning enabled for rollback
- GitHub Actions logs every deploy run

---

Feel free to open issues or submit PRs if you'd like to improve this system!
