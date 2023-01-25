resource "aws_s3_bucket" "main" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
  bucket = var.domain
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" { #tfsec:ignore:aws-s3-encryption-customer-key
  bucket = aws_s3_bucket.main.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = aws_s3_bucket.main.id
  policy = templatefile("s3-cf-oai-policy.tftpl", {
    bucket_name  = aws_s3_bucket.main.id,
    account      = data.aws_caller_identity.account.account_id,
    distribution = aws_cloudfront_distribution.s3.id
  })
}
