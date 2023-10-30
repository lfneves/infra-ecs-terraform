# main.tf

provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

# Create an ECS cluster
resource "aws_ecs_cluster" "delivery_cluster" {
  name = "delivery-ecs-cluster"
}

# Create a task definition
resource "aws_ecs_task_definition" "delivery_task" {
  family                   = "delivery-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn        = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "delivery-container",
    image = "566907801160.dkr.ecr.us-east-1.amazonaws.com/delivery-mvp:latest",
    portMappings = [{
      containerPort = 8099,
      hostPort      = 8099,
    }]
  }])
}

# Create an IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Create an ECS service
resource "aws_ecs_service" "delivery_service" {
  name            = "delivery-ecs-service"
  cluster         = aws_ecs_cluster.delivery_cluster.id
  task_definition = aws_ecs_task_definition.delivery_task.arn

  launch_type = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.delivery_ecs_subnet[0].id]
    security_groups = [aws_security_group.delivery_ecs_sg.id]
  }
}

# Create a VPC and subnet (Replace with your own VPC and subnet definitions)
resource "aws_vpc" "delivery_ecs_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "delivery_ecs_subnet" {
  count = 2
  vpc_id = aws_vpc.delivery_ecs_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Specify the desired availability zones
}

# Create a security group (Replace with your own security group definitions)
resource "aws_security_group" "delivery_ecs_sg" {
  vpc_id = aws_vpc.delivery_ecs_vpc.id

  // Define your security group rules here...
}
