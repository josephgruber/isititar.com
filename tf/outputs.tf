output "s3_bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}
