resource "aws_ecs_cluster" "fargate_cluster" {
  name = "Fargate-cluster"
}

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<EOF
  [
    {
      "name": "example-container",
      "image": "nginx:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  EOF
}

resource "aws_ecs_service" "fargate_service" {
  name            = "fargate-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.fargate_subnets[count.index].id]
    security_groups = [aws_security_group.allow_web.id] # Replace with your security group ID
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example-target-group/abcdef1234567890"
    container_name   = "fargate-example-container"
    container_port   = 80
  }

  desired_count = 1
  deployment_controller {
    type = "ECS"
  }
}
