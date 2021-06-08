output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}


output "network_interface_id" {
  value = "${aws_network_interface.network_interface.id}"
}
