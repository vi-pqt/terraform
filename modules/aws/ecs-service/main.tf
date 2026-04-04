locals {
  common_tags = {
    Project   = var.project_name
    Stage     = var.stage
    ManagedBy = "terraform"
  }
}

#######################
# ECS Service
#######################
resource "aws_ecs_service" "name" {
  count = length(var.service_names)
  name  = "${var.project_name}-${var.service_names[count.index]}"

  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.name[count.index].arn
  desired_count   = var.desired_count
  iam_role        = var.task_role_arn

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
    ignore_changes = [desired_count]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.stage}-${var.service_names[count.index]}"
    Tier = "Private"
  })
}

resource "aws_ecs_task_definition" "name" {
  count                    = length(var.service_names)
  family                   = "${var.project_name}-${var.stage}-${var.service_names[count.index]}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      "name" : "${var.project_name}-${var.service_names[count.index]}",
      "image" : "${var.ecr_url[count.index]}/${var.project_name}/${var.service_names[count.index]}:${var.stage}",
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : keys(var.container_ports)[count.index] == var.service_names[count.index] ? values(var.container_ports)[count.index] : 80,
          "hostPort" : keys(var.container_ports)[count.index] == var.service_names[count.index] ? values(var.container_ports)[count.index] : 80
        }
      ],
      "environment" : [
        {
          "name" : "CONTAINER_PORT",
          "value" : keys(var.container_ports)[count.index] == var.service_names[count.index] ? tostring(values(var.container_ports)[count.index]) : "80"
        }
      ]
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.stage}-${var.service_names[count.index]}-taskdef"
    Tier = "Private"
  })
}
