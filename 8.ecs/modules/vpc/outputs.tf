output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}
/*
output "vpc_public_subnets" {
  value = "${aws_vpc.my_vpc.public_subnets}"
}
*/