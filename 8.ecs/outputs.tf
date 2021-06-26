output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
/*
output "ec2_ip" {
  value = "${module.ec2.ec2_ip}"
}


output "ec2_public_key" {
  value = "${module.ec2.ssh_public_key}"
}


output "ec2_private_key" {
  value = "${module.ec2.ssh_private_key}"
  sensitive = true
}

*/