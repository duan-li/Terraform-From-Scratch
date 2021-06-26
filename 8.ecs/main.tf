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
  /*private_subnets = [
    "172.16.1.0/24",
    "172.16.2.0/24",
  "172.16.3.0/24"]
  public_subnets = [
    "172.16.101.0/24",
    "172.16.102.0/24",
  "172.16.103.0/24"]*/
}

module "network" {
  source           = "./modules/network"
  vpc_id           = "${module.vpc.vpc_id}"
  stack_name = "${var.stack_name}"
}
/*
module "ec2" {
  source           = "./modules/ec2"
  stack_name       = "${var.stack_name}"
  vpc_id           = "${module.vpc.vpc_id}"
  network_interface_id = "${module.network.network_interface_id}"
}
*/

module "autoscaling" {
  source           = "./modules/autoscaling"
  stack_name       = "${var.stack_name}"
  min_spot_instances = 1
  max_spot_instances = 2
  security_group_id = "${module.network.security_group_id}"
  vpc_subnet_id = "${module.network.subnet_id}"
}


module "ecs" {
  source           = "./modules/ecs"
  stack_name       = "${var.stack_name}"
  vpc_id           = "${module.vpc.vpc_id}"
}

