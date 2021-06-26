variable "stack_name" {}
variable "max_spot_instances" {}
variable "min_spot_instances" {}
variable "security_group_id" {}
variable "vpc_subnet_id" {}

############################# start of iam role
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.stack_name}_ecs_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_iam_profile" {
  name = "${var.stack_name}_ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

############################# end of iam role



data "aws_ami" "ecs" {
  # Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-0721c9af7b9b75114 (64-bit x86) / ami-0df6e683778fc4625 (64-bit Arm)
  # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-03d5c68bab01f3496 (64-bit x86) / ami-09d9c897fc36713bf (64-bit Arm)
  # 
  most_recent = true # get the latest version

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "name"
    values = [
      "amzn2-ami-ecs-*"] # ECS optimized image
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = [
    "amazon" # Only official images
  ]
}

resource "aws_autoscaling_group" "ecs_cluster_spot" {
  name_prefix = "${var.stack_name}_asg_spot_"
  termination_policies = [
     "OldestInstance" # When a “scale down” event occurs, which instances to kill first?
  ]
  default_cooldown          = 30
  health_check_grace_period = 30
  max_size                  = var.max_spot_instances
  min_size                  = var.min_spot_instances
  desired_capacity          = var.min_spot_instances

  # Use this launch configuration to define “how” the EC2 instances are to be launched
  launch_configuration      = aws_launch_configuration.ecs_config_launch_config_spot.name

  lifecycle {
    create_before_destroy = true
  }

  # Refer to vpc.tf for more information
  # You could use the private subnets here instead,
  # if you want the EC2 instances to be hidden from the internet
  vpc_zone_identifier = ["${var.vpc_subnet_id}"]

  tags = [
    {
      key                 = "Name"
      value               = var.stack_name,

      # Make sure EC2 instances are tagged with this tag as well
      propagate_at_launch = true
    }
  ]
}

# Attach an autoscaling policy to the spot cluster to target 70% MemoryReservation on the ECS cluster.
/*
resource "aws_autoscaling_policy" "ecs_cluster_scale_policy" {
  name = "${var.stack_name}_ecs_cluster_spot_scale_policy"
  policy_type = "TargetTrackingScaling"
  adjustment_type = "ChangeInCapacity"
  lifecycle {
    ignore_changes = [
      adjustment_type
    ]
  }
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster_spot.name

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name = "ClusterName"
        value = var.stack_name
      }
      metric_name = "MemoryReservation"
      namespace = "AWS/ECS"
      statistic = "Average"
    }
    target_value = 70.0
  }
}
*/



resource "aws_launch_configuration" "ecs_config_launch_config_spot" {
  name_prefix                 = "${var.stack_name}_ecs_cluster_spot"
  image_id                    = data.aws_ami.ecs.id # Use the latest ECS optimized AMI
  instance_type               = "t3a.small" #var.instance_type_spot # e.g. t3a.medium

  # e.g. “0.013”, which represents how much you are willing to pay (per hour) most for every instance
  # See the EC2 Spot Pricing page for more information:
  # https://aws.amazon.com/ec2/spot/pricing/
  # spot_price                  = var.spot_bid_price

  enable_monitoring           = true
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }

  # This user data represents a collection of “scripts” that will be executed the first time the machine starts.
  # This specific example makes sure the EC2 instance is automatically attached to the ECS cluster that we create earlier
  # and marks the instance as purchased through the Spot pricing
  # curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh"  && bash /tmp/ecs-anywhere-install.sh --region "us-west-2" --cluster "add-new" --activation-id "8c51bee3-affb-4a73-9b93-541541b94b33" --activation-code "QpQK8lapq31IoxidN69x"
  # curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh"  && bash /tmp/ecs-anywhere-install.sh --region "us-west-2" --cluster "ecs2" --activation-id "5bfd4e82-f379-415c-8d88-98256da078e4" --activation-code "IAFFT30VsF+ZF7jOWePy"
  user_data = <<EOF
#!/bin/bash
# echo ECS_CLUSTER=${var.stack_name}-ecs-cluster >> /etc/ecs/ecs.config
# echo ECS_INSTANCE_ATTRIBUTES={\"purchase-option\":\"spot\"} >> /etc/ecs/ecs.config
# start ecs
amazon-linux-extras install -y ecs docker
usermod -a -G docker ec2-user

echo "Stop ECS"
/bin/systemctl stop ecs.service
echo "Update ECS config"
bash -c 'echo "ECS_CLUSTER=${var.stack_name}-ecs-cluster" >> /etc/ecs/ecs.config'
echo "Start ECS"
sleep 10
nohup /bin/systemctl start ecs.service &

echo "Done"
EOF

  # We’ll see security groups later
  # security_groups = [aws_security_group.sg_for_ec2_instances.id]
	security_groups = ["${var.security_group_id}"]
  
  # If you want to SSH into the instance and manage it directly:
  # 1. Make sure this key exists in the AWS EC2 dashboard
  # 2. Make sure your local SSH agent has it loaded
  # 3. Make sure the EC2 instances are launched within a public subnet (are accessible from the internet)
  # key_name             = var.ssh_key_name
  # key_name                    = "${aws_key_pair.generated_key.key_name}"

  # Allow the EC2 instances to access AWS resources on your behalf, using this instance profile and the permissions defined there
  # iam_instance_profile = aws_iam_instance_profile.ec2_iam_instance_profile.arn
  # iam_instance_profile = aws_iam_instance_profile.ecs_iam_profile.arn
  iam_instance_profile = aws_iam_instance_profile.ecs_iam_profile.id
}





################################
## Key for EC2
################################

/*
locals {
  public_key_filename  = "./key-${terraform.workspace}.pub"
  private_key_filename = "./key-${terraform.workspace}"
}

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


resource "local_file" "public_key_openssh" {
  depends_on = [ tls_private_key.default ]
  content    = "${tls_private_key.default.public_key_openssh}"
  # filename   = "${local.public_key_filename}"
  filename = "${path.module}/aabbcc.pub"
}

resource "local_file" "private_key_pem" {
  depends_on = [ tls_private_key.default ]
  content    = "${tls_private_key.default.private_key_pem}"
  # filename   = "${path.module}/${local.private_key_filename}"
  filename = "${path.module}/aabbcc.pem"
}

resource "null_resource" "chmod" {
  depends_on = [ local_file.private_key_pem ]

  provisioner "local-exec" {
    command = "chmod 400 ${path.module}/aabbcc.pem" #${path.module}/${local.private_key_filename}
  }
}
*/