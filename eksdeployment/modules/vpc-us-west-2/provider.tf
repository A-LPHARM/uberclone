terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"  
    }
  }
}

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
}