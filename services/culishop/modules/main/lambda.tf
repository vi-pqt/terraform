# ============================================================
# Session 11: Lambda Consumers + SQS Triggers
#
# Split into two phases:
#   Phase 1 (enable_lambda_consumers): Lambda functions + IAM
#   Phase 2 (enable_sqs_triggers): Data lookups + event source mappings
#
# This allows pre-creating Lambdas before students create queues.
# ============================================================

# --- Data sources: look up manually-created SQS queues ---
# Only when sqs_triggers are enabled (queues must exist)

data "aws_sqs_queue" "email" {
  count = local.sqs_triggers_enabled ? 1 : 0
  name  = local.sqs_email_queue
}

data "aws_sqs_queue" "inventory" {
  count = local.sqs_triggers_enabled ? 1 : 0
  name  = local.sqs_inventory_queue
}

data "aws_sqs_queue" "payments" {
  count = local.sqs_triggers_enabled ? 1 : 0
  name  = local.sqs_payments_queue
}

data "aws_sns_topic" "order_events" {
  count = local.sqs_triggers_enabled ? 1 : 0
  name  = local.sns_topic_name
}

# --- Package each Lambda source file into a zip ---

data "archive_file" "lambda" {
  for_each = local.consumer_defs

  type        = "zip"
  source_file = "${path.module}/lambda/${each.value.source_file}.py"
  output_path = "${path.module}/lambda/.zip/${each.value.source_file}.zip"
}

# --- CloudWatch Log Groups ---

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = local.consumer_defs

  name              = "/aws/lambda/${var.project}-${var.environment}-${each.key}-consumer"
  retention_in_days = 7
  tags              = local.messaging_tags
}

# --- Lambda Functions ---

resource "aws_lambda_function" "consumer" {
  for_each = local.consumer_defs

  function_name = "${var.project}-${var.environment}-${each.key}-consumer"
  role          = aws_iam_role.lambda_exec[0].arn
  handler       = "${each.value.source_file}.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.lambda[each.key].output_path
  source_code_hash = data.archive_file.lambda[each.key].output_base64sha256

  tags = local.messaging_tags
}

# --- SQS Event Source Mappings (Phase 2 only) ---

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  for_each = local.trigger_queue_map

  event_source_arn = each.value
  function_name    = aws_lambda_function.consumer[each.key].arn
  batch_size       = 1
  enabled          = true
}
