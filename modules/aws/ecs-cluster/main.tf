locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "terraform"
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy" {

}

#######################
# ECS Cluster
#######################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-${var.stage}-cluster"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.stage}-cluster"
  })
}

#######################
# ECS CloudWatch Log Group
#######################
resource "aws_cloudwatch_log_group" "ecs_cluster_log_group" {
  name              = "/ecs/${var.project_name}-${var.stage}-cluster"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.stage}-ecs-cluster-log-group"
  })
}
