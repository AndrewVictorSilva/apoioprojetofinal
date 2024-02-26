provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#Cria VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    "Name" = "main"
  }
}

# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket  = "aws-cicd-pipeline7023"
    key     = "build/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}