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
