terraform {
  backend "http" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  default_tags {
    tags = var.default_tags
  }
}

data "aws_caller_identity" "account" {}
