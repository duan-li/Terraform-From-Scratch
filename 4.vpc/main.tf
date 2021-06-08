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

################################
## VPC
################################

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-example-aws_vpc"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "tf-example-aws_aig"
  }
}


resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-example-aws_subnet"
  }
}

resource "aws_network_interface" "network_interface" {
  subnet_id   = aws_subnet.my_subnet.id
  # private_ips = ["172.16.10.100"]

  security_groups = ["${aws_security_group.ec2_security_group.id}"]

  tags = {
    Name = "tf-example-network_interface"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id            = aws_vpc.my_vpc.id
  depends_on = [ aws_internet_gateway.my_igw ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_igw.id}"
  }


  tags = {
    Name = "tf-example-route_table"
  }
}

resource "aws_route_table_association" "public_rt_associations" {
  # count          = "${local.nb_azs}"
  subnet_id      = "${aws_subnet.my_subnet.id}"
  route_table_id = "${aws_route_table.my_route_table.id}"
}

################################
## EC2
################################

resource "aws_instance" "app_server" {
  depends_on = [ aws_route_table.my_route_table ]

  ami           = "ami-03d5c68bab01f3496" #ubuntu 20.04
  instance_type = "t2.micro"

  # key_name                    = "${aws_key_pair.generated_key.key_name}"

  network_interface {
    network_interface_id = aws_network_interface.network_interface.id
    device_index         = 0
  } 
  
  tags = {
    Name = "tf-example-aws_instance"
  }
}


################################
## Security group for EC2
################################

resource "aws_security_group" "ec2_security_group" {
  name   = "${var.stack_name}-ec2"
  vpc_id            = aws_vpc.my_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}"
  }
  
}


