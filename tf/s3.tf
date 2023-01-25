resource "aws_s3_bucket" "main" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
  bucket = var.domain
  acl    = "private"
  policy = templatefile("s3-cf-oai-policy.tftpl", {
    oai_arn = aws_cloudfront_origin_access_identity.oai.iam_arn
    bucket  = var.domain
    }
  )
  force_destroy = false

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
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
