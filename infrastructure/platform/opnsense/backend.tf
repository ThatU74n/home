terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.25"
    }
  }
  backend "s3" {
    bucket       = "terraform-u74n"
    key          = "opnsense/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "opnsense" {
  uri            = var.opnsense_api_endpoint
  api_key        = var.opnsense_api_key
  api_secret     = var.opnsense_api_secret
  allow_insecure = true
}
