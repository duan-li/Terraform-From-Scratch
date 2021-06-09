variable "stack_name" {}
variable "vpc_id" {}
variable "network_interface_id" {}

################################
## EC2
################################

resource "aws_instance" "app_server" {
  # depends_on = [ aws_route_table.my_route_table ]

  ami           = "ami-03d5c68bab01f3496" #ubuntu 20.04
  instance_type = "t2.micro"

  key_name                    = "${aws_key_pair.generated_key.key_name}"

  network_interface {
    #network_interface_id = aws_network_interface.network_interface.id
    network_interface_id = "${var.network_interface_id}"
    device_index         = 0
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo service nginx start"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      password = ""
      # private_key = file(pathexpand("${local.private_key_filename}"))
      private_key = "${tls_private_key.default.private_key_pem}"
      # private_key = file("${path.module}/aabbcc.pem")
      # host        = coalesce(self.public_ip, self.private_ip)
      host = self.public_ip
      timeout = "3m"
    }

  } 
  
  tags = {
    Name = "tf-example-aws_instance"
  }
}


################################
## Key for EC2
################################


resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated_key" {
  depends_on = [ tls_private_key.default ]
  
  # key_name   = var.key_name
  key_name   = "key-${var.stack_name}-${terraform.workspace}"
  # public_key = tls_private_key.for_ssh_exec.public_key_openssh
  public_key = "${tls_private_key.default.public_key_openssh}"
}
