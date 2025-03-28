provider "aws" {
  region = var.region
}

# Fetch the VPC ID for "dev"
data "aws_vpc" "vpc_dev" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch the public subnets
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_dev.id]
  }
}

# Fetch the private subnets
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_dev.id]
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-${var.environment}"
  vpc_id      = data.aws_vpc.vpc_dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-${var.environment}"
  vpc_id      = data.aws_vpc.vpc_dev.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic only from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Fetch Secrets from AWS Secrets Manager
# data "aws_secretsmanager_secret" "db_secret" {
#   name = "${var.environment}/rds-creds/rds-${var.service}"
# }

# data "aws_secretsmanager_secret_version" "db_credentials" {
#   secret_id = data.aws_secretsmanager_secret.db_secret.id
# }

# Application Load Balancer
resource "aws_lb" "service_alb" {
  name               = "${var.service}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids
}

# ALB Target Group
resource "aws_lb_target_group" "service_tg" {
  name        = "${var.service}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc_dev.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# HTTPS Listener
resource "aws_lb_listener" "service_https_listener" {
    load_balancer_arn = aws_lb.service_alb.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate_validation.service_cert_validation.certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.service_tg.arn
    }
}

# HTTP Listener Redirect to HTTPS (Merged with existing listener)
resource "aws_lb_listener" "service_listener" {
  load_balancer_arn = aws_lb.service_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "service_cluster" {
  name = "ecs-cluster-${var.environment}"
}

resource aws_cloudwatch_log_group "ecs" {
  name              = "/ecs/${var.environment}/${var.service}"
  retention_in_days = 7
}
# ECS Task Definition
resource "aws_ecs_task_definition" "service" {
  family                   = "${var.service}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "${var.service}-${var.environment}"
      image     = var.container_definitions.service.image
      cpu       = 256
      memory    = 512
      tags =    {
          Name = "${var.service}-${var.environment}"
          environment = var.environment
          service = var.service
          ManagedBy = "Terraform"
        }
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      
      environment = var.container_definitions.service.environment != null ? var.container_definitions.service.environment : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}/${var.service}"
          awslogs-create-group  = "true"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
# ECS Service Auto Scaling Target

resource "aws_appautoscaling_target" "service" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.service_cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 5
}

# ECS Service Auto Scaling Policy for CPU
resource "aws_appautoscaling_policy" "service_cpu" {
  name               = "${var.service}-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# ECS Service Auto Scaling Policy for Memory
resource "aws_appautoscaling_policy" "service_memory" {
  name               = "${var.service}-memory-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.service}-${var.environment}"
  cluster         = aws_ecs_cluster.service_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_tg.arn
    container_name   = "${var.service}-${var.environment}"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.service_https_listener, aws_lb_listener.service_listener]
}

