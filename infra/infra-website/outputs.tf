output "s3_bucket_name" {
  description = "Name of the website S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3.id
}
