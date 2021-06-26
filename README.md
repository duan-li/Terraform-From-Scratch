# Terraform From Scratch


## Getting started

1. create file `main.tf` in `1.docker` directory
2. run `terraform init`
3. run `terraform apply`
4. access `localhost:8000`
6. run `terraform destroy`


## With AWS

1. run `aws configure`
2. create file `main.tf` in `1.simple-aws` directory
3. run `terraform init`
4. run `terraform fmt`
5. run `terraform validate`
6. run `terraform plan` to prepare
7. run `terraform apply` to apply
8. run `terraform destroy`


## Module

Useing `-auto-approve` skip interactive approval of applying.


## Output

Run `terraform output` after `apply`.




## Amazon linux ECS agent

```bash
#!/bin/bash -x
# yum update -y
# yum install epel-release docker amazon-ssm-agent -y
#!/bin/bash
amazon-linux-extras install -y ecs docker
bash -c 'echo "ECS_CLUSTER=cluster-name" >> /etc/ecs/ecs.config'
usermod -a -G docker ec2-user
service docker start
service ecs start
echo "Done"
```



## References

* [How To Deploy A LAMP Stack In AWS Using Terraform](https://cloudaffaire.com/how-to-deploy-a-lamp-stack-in-aws-using-terraform/)
* [Stop manually provisioning AWS for Laravel — use Terraform instead](https://hackernoon.com/stop-manually-provisioning-aws-for-laravel-use-terraform-instead-11b8b360617c)
* [li0nel/laravel-terraform](https://github.com/li0nel/laravel-terraform/tree/master/terraform)
* [rossedman/aws-terraform-laravel Archived](https://github.com/rossedman/aws-terraform-laravel/blob/master/terraform/modules/autoscaling/main.tf)
* [hashicorp/aws documents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [arminc/terraform-ecs](https://github.com/arminc/terraform-ecs)
* [Terraform ECS Example](https://www.metosin.fi/blog/terraform-ecs-example/)
* [Terraform ECS Example repo FARGATE](https://github.com/metosin/cloud-busting)
* [Provisioning an AWS ECS cluster using Terraform](https://www.scavasoft.com/terraform-aws-ecs-cluster-provision/)
* [Provisioning an AWS ECS cluster using Terraform](https://github.com/scavasoft/terraform-aws-ecs-cluster)
* [ECS examples by Module ECS document](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/examples/complete-ecs)