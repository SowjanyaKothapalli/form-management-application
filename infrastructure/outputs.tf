output "frontend_bucket_name" {
  description = "Name of S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "frontend_website_domain" {
  description = "S3 website domain"
  value       = aws_s3_bucket_website_configuration.frontend.website_domain
}

output "api_gateway_url" {
  description = "URL of API Gateway to access backend"
  value       = aws_apigatewayv2_stage.backend_stage.invoke_url
}

output "lambda_function_name" {
  description = "Name of Lambda function for backend"
  value       = aws_lambda_function.backend.function_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (if enabled)"
  value       = var.create_cloudfront ? aws_cloudfront_distribution.frontend[0].domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if enabled)"
  value       = var.create_cloudfront ? aws_cloudfront_distribution.frontend[0].id : null
}

output "deployment_instructions" {
  description = "Instructions for deploying frontend and backend"
  value       = <<-EOT
    Frontend Deployment:
    1. Build the frontend: cd ../frontend && npm run build
    2. Upload to S3: aws s3 sync dist/ s3://${aws_s3_bucket.frontend.bucket}/
    3. Access frontend at: http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}
    ${var.create_cloudfront ? "   - Or via CloudFront: https://${aws_cloudfront_distribution.frontend[0].domain_name}" : ""}
    
    Backend Configuration:
    1. Update API URL in your frontend code to: ${aws_apigatewayv2_stage.backend_stage.invoke_url}
  EOT
}
