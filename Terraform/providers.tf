terraform {
  required_providers {
    # Initiate AWS provider
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }
  }

  backend "s3" {
    # Initiate S3 bucket as backend
    bucket = "eks-2048"
    region = "eu-west-2"
    key    = "terraform.tfstate"
  }
}

