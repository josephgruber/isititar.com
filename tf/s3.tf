resource "aws_s3_bucket" "main" {
  bucket = var.domain
  acl    = "private"
  policy = templatefile("s3-cf-oai-policy.json", {
    oai_arn = "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
    bucket  = "${var.domain}"
    }
  )
  force_destroy = false

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
