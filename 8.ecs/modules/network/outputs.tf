output "security_group_id" {
	value = "${aws_security_group.ec2_security_group.id}"
}

output "subnet_id" {
	value = "${aws_subnet.my_subnet.id}"
}


output "network_interface_id" {
  value = "${aws_network_interface.network_interface.id}"
}
