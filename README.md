# Terraform From Scratch


## Getting started

1. create file `main.tf` 
2. run `terraform init`
3. run `terraform apply`
4. access `localhost:8000`
6. run `terraform destroy`

**main.tf**

```js
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
```

## With AWS

1. run `aws configure`
2. create file `main.tf`.
3. run `terraform init`
4. run `terraform fmt`
5. run `terraform validate`
6. run `terraform plan` to prepare
7. run `terraform apply` to apply
8. run `terraform destroy`

```js
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.4"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

```
