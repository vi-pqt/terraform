locals {
  common_tags = {
    Project   = var.project_name
    Stage     = var.stage
    ManagedBy = "terraform"
  }
}

data "template_file" "taskdef_template" {
  count_service_name   = length(var.service_name)
  count_ecr_url        = length(var.ecr_url)
  count_container_port = length(var.container_port)
  template             = file("${path.module}/task_definition/taskdef_template.json")

  vars = {
    project_name   = var.project_name
    stage          = var.stage
    ecr_url        = var.ecr_url
    service_name   = var.service_name
    container_port = var.container_port
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

  container_definitions = data.template_file.taskdef_template[count.index].rendered

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.stage}-${var.service_names[count.index]}-taskdef"
  })
}
