terraform {
  required_version = "1.12.2"
  required_providers {
    # Initiate AWS provider
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }

  }

  backend "s3" {
    # Initiate S3 bucket as backend
    bucket       = "eks-2048"
    region       = "eu-west-2"
    key          = "terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-west-2"
}


provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
