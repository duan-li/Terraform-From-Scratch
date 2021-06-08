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

variable "stack_name" {}
variable "vpc_id" {}

module "vpc" {
  source           = "./modules/vpc"
  stack_name = "${var.stack_name}"
}

module "ec2" {
  source           = "./modules/ec2"
  stack_name       = "${var.stack_name}"
  vpc_id           = "${module.vpc.vpc_id}"
  network_interface_id = "${module.vpc.network_interface_id}"
}

