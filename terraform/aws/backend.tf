terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket  = "minikube-terraform-toc"
    key     = "zi.wang/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "ap-southeast-1"
}