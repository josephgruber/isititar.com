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
          AWS = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
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
