locals {
  ecs_trust_policy = file("${path.module}/policy/ecs-trust-policy.json")

  ecs_task_role_policy = templatefile("${path.module}/policy/ecs-task-policy.json", {
    region       = var.region
    account_id   = var.aws_account_id
    project_name = var.project_name
  })

  ecs_task_execution_role_policy = file("${path.module}/policy/ecs-task-execution-policy.json")
}

#######################
# IAM ECS Task, Execution Role
#######################
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.stage}-ecs-task-role"

  assume_role_policy = local.ecs_trust_policy

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-ecs-task-role"
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.stage}-ecs-task-execution-role"

  assume_role_policy = local.ecs_trust_policy

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-ecs-task-execution-role"
  })
}

#######################
# IAM ECS Task, Execution Role Policy
#######################
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "${var.project_name}-${var.stage}-ecs-task-role-policy"

  role = aws_iam_role.ecs_task_role.id

  policy = local.ecs_task_role_policy
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name = "${var.project_name}-${var.stage}-ecs-task-execution-role-policy"

  role = aws_iam_role.ecs_task_execution_role.id

  policy = local.ecs_task_execution_role_policy
}
