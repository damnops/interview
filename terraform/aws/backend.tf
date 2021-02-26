terraform {
  backend "s3" {
    bucket         = "minikube-terraform-toc"
    key            = "zhenyu.li/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-1"
}
