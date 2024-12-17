output "frontend_website_url" {
  description = "The URL of hello-devops website"
  value       = aws_s3_bucket_website_configuration.frontend_bucket_website.website_endpoint
}
