terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "toc-devops-interview"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
}
