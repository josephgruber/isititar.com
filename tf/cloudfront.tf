data "aws_cloudfront_cache_policy" "cache_policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "access-identity-${var.domain}"
}

resource "aws_cloudfront_distribution" "distribution" { #tfsec:ignore:aws-cloudfront-enable-waf tfsec:ignore:aws-cloudfront-enable-logging
  origin {
    domain_name         = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id           = "S3-${var.domain}"
    connection_attempts = 3
    connection_timeout  = 10

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  aliases             = [var.domain]
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_policy.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.domain}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}
