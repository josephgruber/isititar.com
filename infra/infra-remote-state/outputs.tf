data "aws_region" "current" {}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.this.id
}

output "terraform_backend_config" {
  description = "Configuration for Terraform backend"
  value       = <<-EOT
    terraform {
        backend "s3" {
            bucket         = "${aws_s3_bucket.this.id}"
            encrypt        = true
            key            = "project_name/terraform.tfstate"
            region         = ${data.aws_region.current.region}
            use_lockfile   = true
        }
    }
    EOT
}
