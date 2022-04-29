output "bucket_domain_name" {
    description = "Domain name of the bucket"
    value = aws_s3_bucket.site.website_endpoint
}