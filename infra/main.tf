provider "aws" {
  region = "sa-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-758724857051"
    key    = "dev/resources/valheimcluster.tfstate"
    region = "sa-east-1"
  }
}

resource "aws_ecs_cluster" "valheim_cluster" {
  name = "ValheimDedicatedServerCluster"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/ValheimServerTask/"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "valheim_task" {
  family                   = "ValheimDedicatedServerTask"
  container_definitions    = jsonencode([
    {
      name      = "ValheimServer",
      image     = "lloesche/valheim-server",
      cpu       = 2048,
      memory    = 4096,
      essential = true,
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = "sa-east-1"
          awslogs-stream-prefix = "steam"
        }
      },
      portMappings = [
        {
          containerPort = 2456
          hostPort      = 2456
          protocol      = "udp"
        },
        {
          containerPort = 2457
          hostPort      = 2457
          protocol      = "udp"
        },
        {
          containerPort = 2458
          hostPort      = 2458
          protocol      = "udp"
        }
      ],
      environment = [
        {
          name  = "SERVER_NAME"
          value = "My Valheim Server"
        },
        {
          name  = "WORLD_NAME"
          value = "MyWorld"
        },
        {
          name  = "SERVER_PASS"
          value = "mypass"
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "valheim_service" {
  name            = "ValheimService"
  cluster         = aws_ecs_cluster.valheim_cluster.id
  task_definition = aws_ecs_task_definition.valheim_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default_subnets.ids
    security_groups = [aws_security_group.valheim_sg.id]
    assign_public_ip = true
  }

  desired_count = 0
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ValheimTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecs-task-execution-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "valheim_sg" {
  name        = "valheim-sg"
  description = "Allow traffic to Valheim server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2456
    to_port     = 2458
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

