terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }

  required_version = "1.5.5"

  backend "s3" {
    bucket = "reportdataanalysis-aa.dev.apilab.bancodelaustro.com"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc_dev" {
  source = "../../modules/vpc"

  name            = "dev"
  cidr_block      = "10.0.0.0/24"
  private_subnets = ["10.0.0.0/27", "10.0.0.32/27", "10.0.0.64/27"]
  private_azs     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tags = {
    env = "dev"
  }
}