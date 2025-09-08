variable "default_tags" {
  default = {
    "ManagedBy" = "Terraform"
    "Project"   = "isititar.com"
  }
  description = "Key-value map of default tags to add to resources"
  type        = map(string)
}

variable "s3_bucket_name_prefix" {
  default     = "tf-state"
  description = "Prefix for the S3 bucket name to store Terraform state"
  type        = string
}
