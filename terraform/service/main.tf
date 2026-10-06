data "aws_caller_identity" "current" {}

data "aws_iam_role" "task_execution" {
  name = var.task_execution_role_name
}

data "aws_iam_role" "task" {
  name = var.task_role_name
}

data "aws_secretsmanager_secret" "master_key" {
  name = "${var.project}/llm-for-dev/litellm/master-key"
}

# Security group for the ALB — allows JPLnet inbound on HTTP:80
# TODO: switch to HTTPS:443 once CloudFront distribution with DNS is in place
# TODO: restrict inbound to CloudFront managed prefix list when CloudFront is activated
resource "aws_security_group" "litellm_alb" {
  name        = "${var.venue}-litellm-alb"
  description = "Allow HTTP from JPLnet to LiteLLM ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.jplnet_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ECS tasks — only reachable from the ALB
resource "aws_security_group" "litellm" {
  name        = "${var.venue}-litellm"
  description = "Allow ALB to access LiteLLM ECS tasks on ports 4000-4001"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 4000
    to_port         = 4001
    protocol        = "tcp"
    security_groups = [aws_security_group.litellm_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "litellm" {
  name               = "${var.venue}-litellm"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.litellm_alb.id]
  subnets            = coalesce(var.alb_subnet_ids, var.subnet_ids)
}

resource "aws_lb_target_group" "litellm" {
  name        = "${var.venue}-litellm"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health/readiness"
    port                = "4000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }
}

# TODO: switch port to 443 and add certificate_arn when CloudFront/DNS is ready
resource "aws_lb_listener" "litellm" {
  load_balancer_arn = aws_lb.litellm.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.litellm.arn
  }
}

resource "aws_cloudwatch_log_group" "litellm" {
  name              = "/ecs/${var.venue}-litellm"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "litellm" {
  name = "${var.venue}-litellm"
}

resource "aws_ecs_task_definition" "litellm" {
  family                   = "${var.venue}-llm-for-developers-litellm-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  task_role_arn            = data.aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "litellm"
      image     = "nasapds/litellm-freehealth:terraform-b1360c9bad47eb6fe40729235a66717f6ecb0ea6"
      essential = true

      portMappings = [
        { containerPort = 4000, protocol = "tcp" },
        # port 4001 exposes the free /health endpoint used by the ALB target group
        { containerPort = 4001, protocol = "tcp" }
      ]

      environment = [
        { name = "DB_SECRET_ARN", value = var.db_secret_arn }
      ]

      secrets = [
        {
          name      = "LITELLM_MASTER_KEY"
          valueFrom = data.aws_secretsmanager_secret.master_key.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.litellm.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "litellm"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "litellm" {
  name            = "${var.venue}-litellm"
  cluster         = aws_ecs_cluster.litellm.id
  task_definition = aws_ecs_task_definition.litellm.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.litellm.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.litellm.arn
    container_name   = "litellm"
    container_port   = 4000
  }

  depends_on = [aws_lb_listener.litellm]
}
