terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "tf-state-20250908005322033500000001"
    encrypt      = true
    key          = "infra-remote-state/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_version = "~> 1.10"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.default_tags
  }
}
