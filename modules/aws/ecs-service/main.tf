locals {
  full_name = "${var.project}-${var.environment}-${var.service_name}"
  log_group = "/ecs/${var.project}/${var.environment}/${var.service_name}"

  env_list = [for k, v in var.environment_variables : {
    name  = k
    value = v
  }]

  container_definition = {
    name      = var.service_name
    image     = var.image
    cpu       = var.cpu
    memory    = var.memory
    essential = true

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
      name          = var.service_name
    }]

    environment = local.env_list

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = local.log_group
        "awslogs-region"        = data.aws_region.current.id
        "awslogs-stream-prefix" = var.service_name
      }
    }

    healthCheck = var.health_check_command != null ? {
      command     = var.health_check_command
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    } : null
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group
  retention_in_days = 7

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "Terraform"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.full_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([local.container_definition])

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "Terraform"
  })
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

  force_new_deployment = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = var.service_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.service_connect_enabled ? [1] : []
    content {
      enabled   = true
      namespace = var.namespace_arn

      dynamic "service" {
        for_each = var.service_connect_role == "client_server" ? [1] : []
        content {
          port_name      = var.service_name
          discovery_name = var.service_name
          client_alias {
            port     = var.container_port
            dns_name = "${var.service_name}.${var.namespace_name}"
          }
        }
      }
    }
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "Terraform"
  })

  depends_on = [aws_cloudwatch_log_group.this]
}
