variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  type = map(string)
  default = {
    Project = "isititar.com"
  }
}

variable "domain" {
  description = "Domain"
  type        = string
  default     = "isititar.com"
}
