variable "stack_name" {}
variable "vpc_id" {}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.stack_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
  	Name = "${var.stack_name}-ecs-cluster"
  }
}


resource "aws_ecs_task_definition" "httpd" {
  family = "define-httpd"
  container_definitions = jsonencode([
    {
      name      = "nginx-httpd"
      image     = "public.ecr.aws/nginx/nginx"
      cpu       = 1
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

}


resource "aws_ecs_service" "ecs_service" {
  name 			  = "${var.stack_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id

  desired_count   = 1
  task_definition = aws_ecs_task_definition.httpd.arn



  tags = {
  	Name = "${var.stack_name}-ecs-service"
  }
}	