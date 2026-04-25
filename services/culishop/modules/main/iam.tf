module "iam" {
  source = "../../../../modules/aws/iam-ecs"

  project     = var.project
  environment = var.environment
}

# ============================================================
# Session 11: Messaging permissions for checkoutservice
# ============================================================

resource "aws_iam_role_policy" "ecs_task_messaging" {
  count = var.enable_messaging ? 1 : 0
  name  = "messaging-publish"
  role  = "${var.project}-${var.environment}-ecs-task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowSNSPublish"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [data.aws_sns_topic.order_events[0].arn]
      },
      {
        Sid      = "AllowSQSSendPayment"
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = [data.aws_sqs_queue.payments[0].arn]
      },
    ]
  })
}
