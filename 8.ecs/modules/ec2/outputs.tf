output "ec2_ip" {
  value = "${aws_instance.app_server.public_ip}"
}

output "ssh_public_key" {
  value = "${tls_private_key.default.public_key_pem}"
}

output "ssh_private_key" {
  value = "${tls_private_key.default.private_key_pem}"
}
