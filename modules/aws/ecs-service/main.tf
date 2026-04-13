#######################
# ECS Service
#######################
resource "aws_ecs_service" "ecs_services" {
  name = "${var.project_name}-${var.service_name}"

  cluster                           = var.ecs_cluster_id
  health_check_grace_period_seconds = 90
  launch_type                       = "FARGATE"
  task_definition                   = aws_ecs_task_definition.ecs_taskdef.arn
  desired_count                     = var.desired_count

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.private_sg
    assign_public_ip = var.assign_public_ip
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  deployment_circuit_breaker {
    enable   = var.is_deployment_circuit_breaker_enable
    rollback = var.is_deployment_circuit_breaker_rollback
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      health_check_grace_period_seconds
    ]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-${var.service_name}"
    Tier = "Private"
  })
}

resource "aws_ecs_task_definition" "ecs_taskdef" {
  family                   = "${var.project_name}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      "name" : "${var.project_name}-${var.service_name}",
      "image" : "${var.ecr_url}/${var.project_name}/${var.service_name}:${var.stage}",
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : keys(var.container_ports) == var.service_name ? values(var.container_ports) : 80,
          "hostPort" : keys(var.container_ports) == var.service_name ? values(var.container_ports) : 80
        }
      ],
      "environment" : [
        {
          "name" : "CONTAINER_PORT",
          "value" : keys(var.container_ports) == var.service_name ? tostring(values(var.container_ports)) : "80"
        }
      ]
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-${var.service_name}-taskdef"
    Tier = "Private"
  })
}
