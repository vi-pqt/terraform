# ============================================================
# Session 11: Messaging locals
# Variables are in variables.tf — this file has locals only.
# ============================================================

locals {
  lambda_consumers_enabled = var.enable_lambda_consumers || var.enable_messaging
  sqs_triggers_enabled     = var.enable_sqs_triggers || var.enable_messaging

  messaging_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Session     = "11"
  }

  sns_topic_name      = "${var.project}-${var.environment}-order-events"
  sqs_email_queue     = "${var.project}-${var.environment}-email-queue"
  sqs_inventory_queue = "${var.project}-${var.environment}-inventory-queue"
  sqs_payments_queue  = "${var.project}-${var.environment}-payments-queue.fifo"

  consumer_defs = local.lambda_consumers_enabled ? {
    email     = { source_file = "email_consumer" }
    inventory = { source_file = "inventory_consumer" }
    payment   = { source_file = "payment_consumer" }
  } : {}

  trigger_queue_map = local.sqs_triggers_enabled ? {
    email     = data.aws_sqs_queue.email[0].arn
    inventory = data.aws_sqs_queue.inventory[0].arn
    payment   = data.aws_sqs_queue.payments[0].arn
  } : {}
}
