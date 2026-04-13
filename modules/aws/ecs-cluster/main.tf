#######################
# Service Connect
#######################
resource "aws_service_discovery_http_namespace" "this" {
  name        = var.namespace
  description = "${var.project_name}-${var.stage} Service Connect namespace"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-service-connect"
  })
}

#######################
# ECS Cluster
#######################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-${var.stage}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.this.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-cluster"
    Tier = "Private"
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

#######################
# ECS CloudWatch Log Group
#######################
resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name              = "/ecs/${var.project_name}-${var.stage}-cluster"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-ecs-cluster-log-group"
    Tier = "Private"
  })
}
