locals {
    region               = "us-east-1"
    cluster_name         = "k8s-cluster-production"
    zone1                = "us-east-1a"
    zone2                = "us-east-1b"
    azs                  = [local.zone1, local.zone2]
    environment          = "k8s-Production"
    eks_version          = "1.30"
    tags = {
        Environment = "production"
    }
}


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.64.0"
    }

    # kubernetes = {
    #   source = "hashicorp/kubernetes"
    #   version = "2.32.0"
    # }
  }
}

provider "aws" {
  region = "us-east-1" 
}

provider "kubernetes" {
  config_path = "~/.kube/config"

  host                   = data.aws_eks_cluster.k8s-production.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8s-production.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.k8s-production.token
}