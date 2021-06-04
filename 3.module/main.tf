terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.15.5"
}


provider "aws" {
  profile = "default"

  region = "us-west-2"
  # region = "ap-southeast-2"
  
  shared_credentials_file = "/root/.aws/credentials"
  
}

module "ec2" {
  source           = "./modules"
}