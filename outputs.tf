output "website_bucket_domain" {
  description = "Domain name of the bucket"
  value       = module.website_s3_bucket.bucket_domain_name
}

output "base_url_apigateway" {
  description = "Base url for api gateway"
  value = module.rest_apigateway.url
}

output "Test" {
  value = module.lambda_functions.arn
}

