data "aws_caller_identity" "account" {}

locals {
  s3_origin_id = "s3IsItITAR"
}

# =================================================================================
# S3 Bucket for Website Content
# =================================================================================
# trivy:ignore:s3-bucket-logging # Logging not required for this use case
resource "aws_s3_bucket" "main" { # trivy:ignore:AVD-AWS-0320 # TODO: Rename bucket to pass AVD
  bucket = var.domain

  lifecycle {
    prevent_destroy = true
  }
}

# trivy:ignore:AVD-AWS-0132 # AWS S3 managed key is acceptable for this use case
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = aws_s3_bucket.main.id
  policy = templatefile("templates/s3-cf-oac-policy.tftpl", {
    bucket_name  = aws_s3_bucket.main.id,
    account      = data.aws_caller_identity.account.account_id,
    distribution = aws_cloudfront_distribution.s3.id
  })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# trivy:ignore:AVD-AWS-0090 # Versioning disabled as it is not required for this use case
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Disabled"
  }
}

# =================================================================================
# Cloudfront Distribution for Website
# =================================================================================
data "aws_cloudfront_cache_policy" "cache_policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "s3" { #tfsec:ignore:aws-cloudfront-enable-logging tfsec:ignore:aws-cloudfront-enable-waf
  aliases             = [var.domain]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.main.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
    origin_id                = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_policy.id
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = aws_s3_bucket.main.bucket_domain_name
  description                       = "-"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# =================================================================================
# Certificate Manager for Cloudfront Distribution
# =================================================================================
resource "aws_acm_certificate" "cloudfront_certificate" {
  domain_name       = var.domain
  validation_method = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "acm_validation" {
  certificate_arn         = aws_acm_certificate.cloudfront_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.acm : record.fqdn]
}

# =================================================================================
# Route 53 DNS Records
# =================================================================================
resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "nameservers" {
  zone_id         = aws_route53_zone.zone.zone_id
  name            = var.domain
  type            = "NS"
  ttl             = 172800
  allow_overwrite = true

  records = [
    "${aws_route53_zone.zone.name_servers[0]}.",
    "${aws_route53_zone.zone.name_servers[1]}.",
    "${aws_route53_zone.zone.name_servers[2]}.",
    "${aws_route53_zone.zone.name_servers[3]}."
  ]
}

resource "aws_route53_record" "soa" {
  zone_id         = aws_route53_zone.zone.zone_id
  name            = var.domain
  type            = "SOA"
  ttl             = 900
  allow_overwrite = true

  records = ["${aws_route53_zone.zone.name_servers[2]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}

resource "aws_kms_key" "ksk" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "ECC_NIST_P256"
  key_usage                          = "SIGN_VERIFY"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "dnssec-policy",
    "Statement" : [
      {
        Sid : "Enable IAM User Permissions",
        Effect : "Allow",
        Principal : {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.account.account_id}:user/gitlab"
          ]
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow Route 53 DNSSEC Service",
        Effect : "Allow",
        Principal : {
          Service : "dnssec-route53.amazonaws.com"
        },
        Action : [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign"
        ],
        Resource : "*",
        Condition : {
          StringEquals : {
            "aws:SourceAccount" : data.aws_caller_identity.account.account_id
          },
          ArnLike : {
            "aws:SourceArn" : "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Sid : "Allow Route 53 DNSSEC to CreateGrant",
        Effect : "Allow",
        Principal : {
          Service : "dnssec-route53.amazonaws.com"
        },
        Action : "kms:CreateGrant",
        Resource : "*",
        Condition : {
          Bool : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_route53_key_signing_key" "ksk" {
  hosted_zone_id             = aws_route53_zone.zone.zone_id
  key_management_service_arn = aws_kms_key.ksk.arn
  name                       = "domain_ksk"
}

resource "aws_route53_hosted_zone_dnssec" "dnssec" {
  depends_on = [
    aws_route53_key_signing_key.ksk
  ]
  hosted_zone_id = aws_route53_zone.zone.zone_id
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3.domain_name
    zone_id                = aws_cloudfront_distribution.s3.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "atproto" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "_atproto.${var.domain}"
  type    = "TXT"
  ttl     = "3600"
  records = [var.atproto_did]
}
