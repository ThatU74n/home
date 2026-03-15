terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
  backend "s3" {
    bucket       = "terraform-u74n"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true

  }
}


#provider "aws" {
#  region     = "ap-southeast-1"
#  access_key = data.vault_generic_secret.aws_kv.data["aws_access_key"]
#  secret_key = data.vault_generic_secret.aws_kv.data["aws_secret_key"]
#}

provider "proxmox" {
  endpoint  = "https://192.168.1.7:8006/api2/json"
  api_token = var.proxmox_api_token
  insecure  = true
}




