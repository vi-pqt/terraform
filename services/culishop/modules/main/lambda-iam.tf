# ============================================================
# Session 11: Lambda Execution Role
#
# Phase 1 (enable_lambda_consumers): Role + basic execution + broad SQS pattern
# Phase 2 (enable_sqs_triggers): Tightened to exact queue ARNs
# ============================================================

data "aws_iam_policy_document" "lambda_assume" {
  count = local.lambda_consumers_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  count              = local.lambda_consumers_enabled ? 1 : 0
  name               = "${var.project}-${var.environment}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume[0].json

  tags = local.messaging_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = local.lambda_consumers_enabled ? 1 : 0
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SQS consume policy — uses exact ARNs when triggers enabled, pattern when only Lambdas
resource "aws_iam_role_policy" "lambda_sqs" {
  count = local.lambda_consumers_enabled ? 1 : 0
  name  = "sqs-consume"
  role  = aws_iam_role.lambda_exec[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
      ]
      Resource = local.sqs_triggers_enabled ? [
        data.aws_sqs_queue.email[0].arn,
        data.aws_sqs_queue.inventory[0].arn,
        data.aws_sqs_queue.payments[0].arn,
      ] : [
        # Pattern-based: allow any culishop-lab queue (tightened when triggers enabled)
        "arn:aws:sqs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.project}-${var.environment}-*"
      ]
    }]
  })
}
