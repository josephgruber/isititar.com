resource "aws_s3_bucket" "main" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-encryption
  bucket = var.domain
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = aws_s3_bucket.main.id
  policy = templatefile("s3-cf-oac-policy.tftpl", {
    bucket_name  = aws_s3_bucket.main.id,
    account      = data.aws_caller_identity.account.account_id,
    distribution = aws_cloudfront_distribution.s3.id
  })
}
